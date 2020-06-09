# frozen_string_literal: true

require "json"
require "logger"
require "pathname"
require "zeitwerk"

module Ramverk
  # Application configuration.
  class Configuration
    require_relative "configuration/middleware"

    # Project root path.
    #
    # @return [Pathname]
    attr_reader :root

    # Parsers used to read. POST data.
    #
    # @return [Hash<Symbol => Proc>]
    attr_accessor :body_parsers

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

    # Autoloader object.
    #
    # @return [Zeitwerk::Loader]
    attr_reader :autoload_loader

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

    # Controller configuration.
    #
    # @return [Ramverk::Controller::Configuration]
    attr_reader :controller

    # @private
    # rubocop:disable Metrics/AbcSize
    def initialize(env: Ramverk.env)
      @env = env
      @dynamic_groups = {}
      @root = Pathname.new(Dir.pwd)
      @body_parsers = {}

      # Middleware
      @middleware = Middleware.new

      # Logging
      @logger = Logger.new(env == :test ? "/dev/null" : $stdout)
      @logger_level = env == :production ? :info : :debug
      @logger_formatter = LOGGER_DEFAULT_FORMATTER
      @logger_filter_params = %w[password password_confirmation]

      # Autoloading
      @autoload_loader = Zeitwerk::Loader.new
      @autoload_paths = []
      @autoload_eager_load = env != :development
      @autoload_reload = env == :development

      # Controller
      @controller = Controller.configuration
    end
    # rubocop:enable Metrics/AbcSize

    # Set project root path.
    #
    # @param value [String, Pathname]
    #
    # @raise [Errno::ENOENT]
    def root=(value)
      @root = Pathname.new(value).realpath
    end

    # Yield the block if the given environment matches the current.
    #
    # @param env [Symbol]
    # @yieldparam config [Ramverk::Configuration]
    #
    # @example
    #   class Application < Ramverk::Application
    #     config.environment :development do
    #     end
    #   end
    def environment(env)
      yield self if env == @env
    end

    # @private
    def boot
      boot_logger
      boot_autoload
      boot_body_parsers

      freeze
    end

    # @private
    def freeze
      @body_parsers.freeze
      @middleware.freeze
      @dynamic_groups.freeze
      @dynamic_groups.each_value(&:freeze)

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

      autoload_paths.each { |path| autoload_loader.push_dir(root.join(path)) }

      if autoload_reload
        autoload_loader.enable_reloading

        require_relative "middleware/reloader"
        middleware.prepend Ramverk::Middleware::Reloader, autoload_loader
      end

      autoload_loader.setup
      autoload_loader.eager_load if autoload_eager_load
    end
    # rubocop:enable Metrics/AbcSize

    # @private
    def boot_body_parsers
      return if !body_parsers || body_parsers.empty?

      require_relative "middleware/body_parser"
      middleware.use Ramverk::Middleware::BodyParser, parsers: body_parsers, logger: logger
    end

    # @private
    def method_missing(meth, *args, &block)
      return super unless meth.to_s.end_with?("=")

      key = meth.to_s.sub("=", "")
      @dynamic_groups[key] = args.first

      define_singleton_method(key) { @dynamic_groups[key] }
    end

    # @private
    # :nocov:
    def respond_to_missing?(name, include_private = false)
      super
    end
    # :nocov:

    # @private
    LOGGER_DEFAULT_FORMATTER = lambda do |severity, time, _progname, message|
      message = { severity: severity, time: time, message: message }
      %(#{message.to_json}\n)
    end
    private_constant :LOGGER_DEFAULT_FORMATTER
  end
end
