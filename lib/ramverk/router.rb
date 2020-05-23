# frozen_string_literal: true

module Ramverk
  # HTTP router for Ramverk.
  #
  # @example Verb routes
  #   endpoint = ->(env) { [200, {}, ["Hello World"]] }
  #
  #   Ramverk.application.routes do
  #     get "/", to: endpoint
  #     post "/", to: endpoint
  #     put "/", to: endpoint
  #     patch "/", to: endpoint
  #     delete "/", to: endpoint
  #     options "/", to: endpoint
  #     trace "/", to: endpoint
  #   end
  #
  # @example Scoped routes
  #   Ramverk.application.routes do
  #     scope "animals", namespace: "species", as: :animals do
  #       scope "mammals", namespace: "mammals", as: :mammals do
  #         get "/cats", to: "cats#index", as: :cats
  #       end
  #     end
  #   end
  #
  #   # /animals/mammals/cats => "species/mammals/cats#index"
  class Router
    # Supported request verbs.
    #
    # @return [Array]
    VERBS = %w[GET POST PUT PATCH DELETE OPTIONS TRACE].freeze

    require_relative "router/route"
    require_relative "router/scope"

    # Base URL used for generating URLs from routes.
    #
    # @return [String]
    attr_reader :base_url

    # Defined routes.
    #
    # @return [Array]
    attr_reader :flat_map

    # Defined routes grouped by verb.
    #
    # @return [Hash]
    attr_reader :verb_map

    # Route names with their associated route.
    #
    # @return [Hash]
    attr_reader :named_map

    # Initializes the router.
    #
    # @param base_url [String]
    #   Base URL used for generating URLs from routes.
    # @yield
    #   Block is evaluated inside the router context.
    def initialize(base_url: "http://localhost:9292", &block)
      @base_url = base_url
      @flat_map = []
      @verb_map = {}
      @named_map = {}

      instance_eval(&block) if block_given?
    end

    # Create a scoped set of routes.
    #
    # @param path [String]
    #   Scope path prefix.
    # @param namespace [String, Symbol]
    #   Scope namespace.
    # @param as [Symbol]
    #   Scope name prefix.
    #
    # @yield
    #   Block is evaluated inside the created scope context.
    #
    # @return [Ramverk::Router::Scope]
    def scope(path = nil, namespace: nil, as: nil, &block)
      Scope.new(self, path, namespace, as, &block)
    end

    # @private
    def add(verb, path, to: nil, as: nil, constraints: {}, &block)
      to = block if block_given?

      route = Route.new(path, to, constraints)

      @flat_map << route
      @verb_map[verb] ||= []
      @verb_map[verb] << route

      if as
        as = Naming.route_name(as)
        raise "a route named ':#{as}' has already been defined" if @named_map.key?(as)
        @named_map[as] = route
      end

      route
    end

    # @private
    VERBS.each do |verb|
      define_method verb.downcase do |path, to: nil, as: nil, constraints: {}, &block|
        add verb, path, to: to, as: as, constraints: constraints, &block
      end
    end

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
  end
end
