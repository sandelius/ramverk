# frozen_string_literal: true

require "logger"
require "pathname"
require "zeitwerk"

require_relative "configuration/middleware"

module Ramverk
  # Project configuration.
  class Configuration
    # Project root path.
    #
    # @return [Pathname]
    attr_reader :root

    # Base URL used for generating URLs from routes.
    #
    # @return [String]
    attr_accessor :base_url

    # Middleware manager.
    #
    # @return [Ramverk::Middleware]
    #
    # @see Ramverk::Middleware
    attr_reader :middleware

    # Application logger.
    #
    # @return [Logger]
    attr_accessor :logger

    # Logger severity level.
    #
    # @return [Symbol]
    attr_accessor :logger_level

    # Logger formatter.
    #
    # @return [Proc]
    attr_accessor :logger_formatter

    # Params to be [FILTERED] out from logs.
    #
    # @return [Array<String>]
    attr_accessor :logger_filter_params

    # Paths to (re)load constants from. All paths should be relative to project
    # root path.
    #
    # @return [Array]
    attr_accessor :autoload_paths

    # Eager loads all files in the root of the #autoload_paths directories,
    # recursively.
    #
    # Disabled by default in `development` and `test` environments.
    #
    # @return [Boolean]
    attr_accessor :autoload_eager_load

    # Reload constants automatically. This is only enabled in `development` by
    # default.
    #
    # Enabled by default in `development` environment.
    #
    # @return [Boolean]
    attr_accessor :autoload_reload

    # @private
    def initialize(env: Ramverk.env)
      @env = env
      @root = Pathname.new(Dir.pwd)

      # Routing
      @base_url = "http://localhost:9292"

      # Middleware
      @middleware = Middleware.new

      # Logging
      @logger = Logger.new(env == :test ? "/dev/null" : $stdout)
      @logger_level = env == :production ? :info : :debug
      @logger_formatter = LOGGER_DEFAULT_FORMATTER
      @logger_filter_params = %w[password password_confirmation]

      # Autoloading
      @autoload_paths = []
      @autoload_eager_load = env != :development
      @autoload_reload = env == :development
    end

    # Yield the block if the given environment matches the current.
    #
    # @param env [Symbol]
    # @yieldparam config [Ramverk::Configuration]
    #
    # @example
    #   class Application < Ramverk::Application
    #     config.environment :development do
    #       config.middleware.use Rack::Static, root: "public", urls: %w[/assets]
    #     end
    #   end
    def environment(env)
      yield self if env == @env
    end

    # Set project root path.
    #
    # @param value [String, Pathname]
    #
    # @raise [Errno::ENOENT] If path does not exist.
    def root=(value)
      @root = Pathname.new(value).realpath
    end

    # @private
    def boot
      boot_logger
      boot_autoload

      freeze
    end

    # @private
    def freeze
      middleware.freeze

      super
    end

    private

    # @private
    def boot_logger
      return unless logger

      logger.level = logger_level
      logger.formatter = logger_formatter
      logger.freeze

      require_relative "middleware/request_logger"
      middleware.prepend Ramverk::Middleware::RequestLogger,
                         logger,
                         logger_filter_params
    end

    # @private
    # rubocop:disable Metrics/AbcSize
    def boot_autoload
      return if !autoload_paths || autoload_paths.empty?

      loader = Zeitwerk::Loader.new

      autoload_paths.each { |path| loader.push_dir(root.join(path)) }

      if autoload_reload
        loader.enable_reloading

        require_relative "middleware/reloader"
        middleware.prepend Ramverk::Middleware::Reloader, loader
      end

      loader.setup
      loader.eager_load if autoload_eager_load
    end
    # rubocop:enable Metrics/AbcSize

    # @private
    LOGGER_DEFAULT_FORMATTER = ->(_, _, _, msg) { "#{msg}\n" }
    private_constant :LOGGER_DEFAULT_FORMATTER
  end
end
