# frozen_string_literal: true

require "logger"
require "forwardable"

require "rack"
require "zeitwerk"
require "rutter"

require_relative "configuration"

module Ramverk
  # Represents a Ramverk application.
  #
  # @abstract
  #
  # @example Mounting (sub) applications
  #   class Application < Ramverk::Application
  #     set :autoload_paths, %w[apps]
  #
  #     set :routes do
  #       mount Api::Application.new, at: "/v1", host: /\Aapi\./
  #       mount Web::Application.new, at: "/"
  #     end
  #   end
  class Application # rubocop:disable Metrics/ClassLength
    # @private
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def self.inherited(base)
      super

      base.class_eval do
        @booted = false
        @events = { pre_boot: [], post_boot: [] }

        @configuration = Configuration.new do
          add :root, Dir.pwd
          add :middleware, []

          # Routing
          add :base_url, "http://localhost:9292"
          add :routes, (proc {})

          # Logging
          add :logger, Logger.new(Ramverk.env?(:test) ? "/dev/null" : $stdout)
          add :logger_level, Ramverk.env?(:production) ? :info : :debug
          add :logger_formatter, LOGGER_DEFAULT_FORMATTER
          add :logger_filter_params, %w[password password_confirmation]

          # Autoloading
          add :autoload_paths, []
          add :autoload_eager_load, !Ramverk.env?(:development)
          add :autoload_reload, Ramverk.env?(:development)
        end

        @container = {
          autoload: Zeitwerk::Loader.new
        }
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    class << self
      extend Forwardable

      def_delegators :@configuration, :add, :set
      def_delegators :@container, :[]=

      # Alias for self.
      #
      # @return [Ramverk::Application]
      #
      # @example
      #   class Application < Ramverk::Application
      #     set :root, "/path/to/root"
      #
      #     app[:root] # => "/path/to/root"
      #     app == self # => true
      #   end
      alias app itself

      # Application configuration object.
      #
      # @return [Ramverk::Configuration]
      attr_reader :configuration

      alias cfg configuration

      # Gets an item from the container.
      #
      # @param key [Symbol]
      #   Item identifier.
      #
      # @return [*]
      def [](key)
        @container.fetch(key)
      end

      # Append a middleware to the stack.
      #
      # @param middleware [Class]
      #   Middleware class.
      # @param *args [*]
      #   Middleware arguments.
      # @param &block [Proc]
      #   Middleware block argument.
      #
      # @example
      #   class Application < Ramverk::Application
      #     use Rack::Head
      #     use Rack::Static, root: "public", urls: %w[/assets]
      #   end
      def use(middleware, *args, &block)
        configuration[:middleware] << [middleware, args, block].freeze
      end

      # Yield the block if the given environment matches the current.
      #
      # @param environment [Symbol]
      # @yieldparam app [Ramverk::Application]
      #
      # @example
      #   class Application < Ramverk::Application
      #     use Rack::Head
      #
      #     env :development do
      #       use Rack::Static, root: "public", urls: %w[/assets]
      #     end
      #   end
      def env(environment)
        yield self if Ramverk.env?(environment)
      end

      # Register a callback that will be evauluated when the event is emitted.
      #
      # @param event [Symbol]
      #   Name of the event.
      # @yieldparam app [Ramverk::Application]
      #
      # @raise [NameError]
      #   If event is unknown.
      #
      # @example
      #   class Application < Ramverk::Application
      #     run :pre_boot do
      #       # Evaluated before boot process
      #     end
      #
      #     run :post_boot do
      #       # Evaluated after boot process, but before freeze
      #     end
      #   end
      def run(event, &block)
        raise NameError, "unknown event ':#{event}'" unless @events.key?(event)

        @events[event] << block
      end

      # Boot the application.
      #
      # Booting the application manually is only needed when you need to use
      # it outside of a web request. Background jobs, like Sidekiq, is one
      # example scenario.
      #
      # @return [self]
      #
      # @example
      #   class Application < Ramverk::Application
      #   end
      #
      #   Application.boot
      def boot
        return self if @booted
        @booted = true

        @events[:pre_boot].each { |cb| cb.call(app) }

        boot_logger
        boot_autoload
        boot_routes

        @events[:post_boot].each { |cb| cb.call(app) }

        freeze
      end

      # @private
      # rubocop:disable Metrics/AbcSize
      def boot_logger
        app[:logger] = cfg[:logger]

        return unless app[:logger]

        require_relative "middleware/request_logger"
        cfg[:middleware].unshift([Ramverk::Middleware::RequestLogger,
                                  [app[:logger], cfg[:logger_filter_params]],
                                  nil])

        app[:logger].level = cfg[:logger_level]
        app[:logger].formatter = cfg[:logger_formatter]
        app[:logger].freeze
      end
      # rubocop:enable Metrics/AbcSize

      # @private
      # rubocop:disable Metrics/AbcSize
      def boot_autoload
        return if cfg[:autoload_paths].empty?

        cfg[:autoload_paths].each do |path|
          app[:autoload].push_dir(File.join(cfg[:root], path))
        end

        if cfg[:autoload_reload]
          app[:autoload].enable_reloading

          require_relative "middleware/reloader"
          cfg[:middleware].unshift([Ramverk::Middleware::Reloader,
                                    [app[:autoload]],
                                    nil])
        end

        app[:autoload].setup
        app[:autoload].eager_load if cfg[:autoload_eager_load]
      end
      # rubocop:enable Metrics/AbcSize

      # @private
      def boot_routes
        app[:router] = Rutter.new(base: cfg[:base_url], &cfg[:routes]).freeze
        app[:routes] = Rutter::Routes.new(app[:router])
      end

      # @private
      def freeze
        @container.freeze
        @configuration.freeze
      end
    end

    # Initializes the application.
    #
    # @private
    def initialize(app: self.class)
      app.boot

      @app = Rack::Builder.new do
        app.configuration[:middleware].each do |(mw, args, block)|
          use mw, *args, &block
        end

        run app[:router]
      end.freeze
    end

    # Rack compatible endpoint.
    #
    # @param env [Hash] Rack environment hash.
    #
    # @return [Array]
    #
    # @private
    def call(env)
      @app.call(env)
    end

    # @private
    LOGGER_DEFAULT_FORMATTER = ->(_, _, _, msg) { "#{msg}\n" }
    private_constant :LOGGER_DEFAULT_FORMATTER
  end
end
