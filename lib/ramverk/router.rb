# frozen_string_literal: true

module Ramverk
  # HTTP router for Ramverk.
  class Router
    # Supported request verbs.
    #
    # @return [Array]
    VERBS = %w[GET POST PUT PATCH DELETE OPTIONS].freeze

    require_relative "router/route"

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

      instance_eval(&block) if block_given?
    end

    # @private
    def add(verb, path, to: nil, constraints: {}, &block)
      to = block if block_given?

      route = Route.new(path, to, constraints)

      @flat_map << route
      @verb_map[verb] ||= []
      @verb_map[verb] << route

      route
    end

    # @private
    VERBS.each do |verb|
      define_method verb.downcase do |path, to: nil, constraints: {}, &block|
        add verb, path, to: to, constraints: constraints, &block
      end
    end

    # @private
    def freeze
      @flat_map.freeze
      @verb_map.each_value(&:freeze)
      @verb_map.freeze

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
