# frozen_string_literal: true

module Ramverk
  # The Controller is responsible for returning a response to the client.
  #
  # Reserved action names:
  #   - request
  #   - params
  #   - headers
  #   - redirect
  #   - render
  #   - call
  class Controller
    require_relative "controller/configuration"

    # @private
    def self.inherited(base)
      super

      base.configuration = config&.dup
      base._filters = _filters&.dup || []
    end

    # @private
    @configuration = Configuration.new

    class << self
      # Controller configuration.
      #
      # @return [Ramverk::Controller::Configuration]
      attr_accessor :configuration

      alias config configuration

      # @private
      attr_accessor :_filters

      # Defined callbacks that's run before the action.
      #
      # @param *filters [Array<Symbol>]
      #   Controller methods name(s) to be called.
      # @param &block [Proc]
      #   Filter as a block.
      #
      # @example
      #   class Books < Ramverk::Controller
      #     before :set_boot
      #
      #     def index
      #       render JSON.generate(@book), as: :json
      #     end
      #
      #     private
      #
      #     def set_book
      #       @book = { title: "Pickaxe" }
      #     end
      #   end
      def before(*filters, &block)
        filters << block if block_given?
        _filters.concat(filters)
      end

      # Skip already defined callbacks.
      #
      # @param *filters [Array<Symbol>]
      #   Filters to be skipped.
      def skip_before(*filters)
        self._filters = _filters - filters
      end

      # @private
      def call(env)
        action = env["router.action"].to_sym

        new(action).call(env)
      end
    end

    # Initialize the controller.
    #
    # @param action [Symbol]
    #   Action/method to be dispatched.
    def initialize(action)
      @_action = action
      @_response = Rack::Response.new([], 200, self.class.configuration.default_headers)
    end

    # Returns response headers that's gonna be sent to the client.
    #
    # @return [Hash]
    def headers
      @_response.headers
    end

    # Request object that hold information about the request.
    #
    # @return [Rack::Request]
    # rubocop:disable Naming/MemoizedInstanceVariableName
    def request
      @_request ||= Rack::Request.new(@_env)
    end
    # rubocop:enable Naming/MemoizedInstanceVariableName

    # Combined request and route parameters.
    #
    # @return [Hash]
    # rubocop:disable Naming/MemoizedInstanceVariableName
    def params
      @_params ||= request.params.merge(@_env["router.params"] || {})
    end
    # rubocop:enable Naming/MemoizedInstanceVariableName

    # Renders a response to the client.
    #
    # @param body [String]
    #   Response body.
    # @param as [Symbol]
    #   Response content type.
    # @param status [Integer]
    #   Response status code.
    #
    # @raise [RuntimeError]
    #   If content type is unknown.
    #
    # @throw :halt
    def render(body, as: nil, status: 200)
      as ||= self.class.configuration.default_format

      type = Rack::Mime::MIME_TYPES.fetch(".#{as}") do
        raise "unkown content type ':#{as}'"
      end

      @_response.content_type = type
      @_response.status = status
      @_response.write(body)

      throw :halt
    end

    # Redirect the request to a another destination.
    #
    # @param target [String]
    #   New destination.
    # @param status [Integer]
    #   Response status code.
    #
    # @throw :halt
    def redirect(target, status: 302)
      @_response.redirect(target, status)

      throw :halt
    end

    # @private
    def call(env)
      @_env = env
      filters = self.class._filters

      catch :halt do
        filters.each do |filter|
          filter.is_a?(Proc) ? instance_eval(&filter) : send(filter)
        end

        public_send(@_action)
      end

      @_response.finish
    end
  end
end
