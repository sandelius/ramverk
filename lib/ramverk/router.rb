# frozen_string_literal: true

module Ramverk
  # HTTP router for Ramverk.
  class Router
    # Supported request verbs.
    #
    # @return [Array]
    VERBS = %w[GET POST PUT PATCH DELETE HEAD OPTIONS TRACE].freeze

    require_relative "router/methods"
    require_relative "router/route"
    require_relative "router/mount"
    require_relative "router/scope"

    include Methods

    # Defined routes.
    #
    # @return [Array]
    attr_reader :flat_map

    # Defined routes grouped by verb.
    #
    # @return [Hash]
    attr_reader :verb_map

    # Defined routes grouped by name.
    #
    # @return [Hash]
    attr_reader :named_map

    # Initialize the router.
    #
    # @yield
    #   Block is evaluated inside the context context.
    def initialize(&block)
      @flat_map = []
      @verb_map = {}
      @named_map = {}
      @anon_controller = Class.new(Controller)

      instance_eval(&block) if block_given?
    end

    # Mount a Rack compatible application to the given path prefix.
    #
    # @param app [#call]
    # @param at [String]
    # @param constraints [Hash]
    # @param host [Regexp]
    #
    # @return [Ramverk::Router::Mount]
    def mount(app, at:, constraints: {}, host: nil)
      @flat_map << route = Mount.new(at, app, constraints, host: host)

      VERBS.each do |verb|
        @verb_map[verb] ||= []
        @verb_map[verb] << route
      end

      route
    end

    # Creates a scoped set of routes.
    #
    # @param path [String]
    # @param namespace [String]
    # @param as [Symbol]
    # @param &block [Proc]
    #
    # @return [Ramverk::Router::Scope]
    def scope(path = nil, namespace: nil, as: nil, &block)
      Scope.new(self, path, namespace, as, &block)
    end

    # @private
    # rubocop:disable Metrics/ParameterLists
    def add(verb, path, to: nil, constraints: {}, as: nil, &block)
      to = @anon_controller.action(block) if block_given?

      raise "missing endpoint, use to: or a block" unless to

      route = Route.new(path, to, constraints)

      @flat_map << route
      @verb_map[verb] ||= []
      @verb_map[verb] << route

      if as
        as = as.to_sym
        raise "duplicate route name ':#{as}'" if @named_map.key?(as)
        @named_map[as] = route
      end

      route
    end
    # rubocop:enable Metrics/ParameterLists

    # @private
    def freeze
      @flat_map.freeze
      @verb_map.each_value(&:freeze)
      @verb_map.freeze
      @named_map.freeze

      super
    end

    # @private
    def call(env)
      request_method = env["REQUEST_METHOD"]

      if (routes = @verb_map[request_method])
        routes.each do |route|
          next unless route.match?(env)

          return route.call(env)
        end
      end

      NOT_FOUND_RESPONSE
    end

    # @private
    NOT_FOUND_RESPONSE = [404, { "X-Cascade" => "pass" }, ["Not Found"]].freeze
    private_constant :NOT_FOUND_RESPONSE
  end
end
