# frozen_string_literal: true

require "pathname"
require "mustermann"

require_relative "../naming"

module Ramverk
  class Router
    # Represenst a single route.
    class Route
      # Path template.
      #
      # @return [String]
      attr_reader :template

      # Route endpoint.
      #
      # @return [Hash]
      attr_reader :endpoint

      # @private
      def initialize(template, endpoint, constraints = {})
        @template = normalize_path(template)
        @pattern = Mustermann.new(@template, capture: constraints)
        @endpoint = endpoint_to_hash(endpoint).freeze

        freeze
      end

      # Matches the route pattern against environment.
      #
      # @param env [Hash]
      #   Rack environment hash.
      #
      # @return [Boolean]
      def match?(env)
        @pattern === env["PATH_INFO"] # rubocop:disable Style/CaseEquality
      end

      # Extract params from the given path.
      #
      # @param path [String]
      #   Path used to extract params from.
      #
      # @return [Hash]
      def params(path)
        @pattern.params(path) || {}
      end

      # @private
      def call(env)
        env["router.params"] ||= {}
        env["router.params"].merge!(params(env["PATH_INFO"]))
        env["router.action"] = endpoint[:action]

        ctrl = endpoint[:controller]
        ctrl = ::Object.const_get(ctrl) if ctrl.is_a?(String)
        ctrl.call(env)
      end

      private

      # @private
      def normalize_path(path)
        Pathname.new("/#{path.to_s.downcase}").cleanpath.to_s
      end

      # @private
      def endpoint_to_hash(endpoint)
        ctrl, action = if endpoint.is_a?(String)
                         ctrl, action = endpoint.split("#")
                         ctrl = Ramverk::Naming.classify(ctrl)
                         [ctrl, action]
                       else
                         [endpoint, nil]
                       end

        { controller: ctrl, action: action }
      end
    end
  end
end
