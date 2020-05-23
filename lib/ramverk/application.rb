# frozen_string_literal: true

require_relative "configuration"
require_relative "router"
require_relative "controller"

module Ramverk
  # Represents a Ramverk application.
  #
  # @abstract
  #
  # @example
  #   class Application < Ramverk::Application
  #     require_relative "routes"
  #
  #     config.autoload_paths << "lib"
  #     config.autoload_paths << "lib/models"
  #     config.autoload_paths << "apps"
  #   end
  class Application
    # @private
    def self.inherited(base)
      super

      base.class_eval do
        @_booted = false
        @_routes = (proc {})
        @_events = { pre_boot: [], post_boot: [] }
        @_configuration = Configuration.new
        @_container = {}
      end

      Ramverk.application = base
    end

    class << self
      # Application configuration object.
      #
      # @return [Ramverk::Configuration]
      def configuration
        @_configuration
      end
      alias config configuration

      # Defines the routes for this application.
      #
      # @yield
      #   Block is evaluated inside the router context.
      #
      # @example
      #   Ramverk.application.routes do
      #     # Router DSL
      #   end
      def routes(&block)
        @_routes = block
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
      #     on :pre_boot do
      #       # Evaluated before boot process
      #     end
      #
      #     on :post_boot do
      #       # Evaluated after boot process, but before freeze
      #     end
      #   end
      def on(event, &block)
        raise NameError, "unknown event ':#{event}'" unless @_events.key?(event)

        @_events[event] << block
      end

      # Gets an item from the container.
      #
      # @param key [Symbol]
      #   Item identifier.
      #
      # @return [*]
      #
      # @raise [KeyError]
      #   If item has not been registered in the container.
      def [](key)
        @_container.fetch(key) do
          raise KeyError, "key ':#{key}' could not be found in the container"
        end
      end

      # Sets an item in the container.
      #
      # @param key [Symbol]
      #   Item identifier.
      # @param value [*]
      #   Item value.
      def []=(key, value)
        @_container[key] = value
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
        return self if @_booted
        @_booted = true

        @_events[:pre_boot].each { |cb| cb.call(self) }

        configuration.boot
        container_boot

        @_events[:post_boot].each { |cb| cb.call(self) }

        freeze
      end

      # @private
      def container_boot
        self[:logger] = configuration.logger
        self[:router] = Router.new(base_url: configuration.base_url, &@_routes).freeze
      end

      # @private
      def freeze
        @_container.freeze

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
