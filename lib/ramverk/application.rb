# frozen_string_literal: true

require "rack"

require_relative "configuration"
require_relative "router"
require_relative "controller"

module Ramverk
  # Represents a Ramverk application.
  class Application
    # @private
    def self.inherited(base)
      super

      base.class_eval do
        @_booted = false
        @_container = {}
        @_events = { pre_boot: [], post_boot: [] }
        @_routes = (proc {})
        @_configuration = Configuration.new
      end

      Ramverk.application = base
    end

    class << self
      # Application configuration.
      #
      # @return [Ramverk::Configuration]
      def configuration
        @_configuration
      end
      alias config configuration

      # Sets an item in the container.
      #
      # @param key [Symbol]
      # @param value [*]
      def []=(key, value)
        @_container[key] = value
      end

      # Get an item from the container.
      #
      # @param key [Symbol]
      #
      # @return [*]
      def [](key)
        @_container.fetch(key)
      end

      # Defines the routes for this application.
      #
      # @yield
      #   Block is evaluated inside the router context.
      #
      # @example
      #   class Application < Ramverk::Application
      #     routes do
      #       # Router DSL
      #     end
      #   end
      def routes(&block)
        @_routes = block
      end

      # Register a callback to be run on the given event.
      #
      # @param name [Symbol]
      # @param &block [Proc]
      #
      # @raise [RuntimeError]
      #   If event name is unknown.
      #
      # @example
      #   class Application < Ramverk::Application
      #     on :pre_boot do
      #       # run before the booting process has started
      #     end
      #
      #     on :post_boot do
      #       # run after the booting process but before freeze
      #     end
      #   end
      def on(name, &block)
        raise "unknown event ':#{name}'" unless @_events.key?(name)

        @_events[name] << block
      end

      # Boot the application.
      #
      # @return [self]
      # rubocop:disable Metrics/AbcSize
      def boot
        return self if @_booted
        @_booted = true

        # :pre_boot event
        @_events[:pre_boot].each { |cb| cb.call(self) }

        configuration.boot
        @_container[:root] = configuration.root
        @_container[:router] = Router.new(&@_routes).freeze
        @_container[:logger] = configuration.logger

        # :post_boot event
        @_events[:post_boot].each { |cb| cb.call(self) }

        freeze
      end
      # rubocop:enable Metrics/AbcSize

      # @private
      def freeze
        @_container.freeze
        @_configuration.freeze

        super
      end
    end

    # Initializes the application.
    #
    # @example
    #   # config.ru
    #
    #   run Ramverk.application.new
    def initialize(app: self.class)
      app.boot

      @app = Rack::Builder.new do
        app.configuration.middleware.stack.each do |(mw, args, block)|
          use mw, *args, &block
        end

        run app[:router]
      end.freeze
    end

    # @private
    def call(env)
      @app.call(env)
    end
  end
end
