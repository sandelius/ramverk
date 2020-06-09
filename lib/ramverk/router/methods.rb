# frozen_string_literal: true

module Ramverk
  class Router
    # Common route emthods.
    module Methods
      # Creates a root route in the current scope named `:root`.
      #
      # @param to [#call, String]
      # @param &block [Proc]
      #
      # @return [Array<Ramverk::Router::Route>]
      def root(to: nil, &block)
        get "/", to: to, as: :root, &block
      end

      # Creates two route that match GET, and HEAD, verbs.
      #
      # @param path [String]
      # @param to [#call, String]
      # @param constraints [Hash]
      # @param &block [Proc]
      #
      # @return [Array<Ramverk::Router::Route>]
      def get(path, to: nil, constraints: {}, as: nil, &block)
        [
          add("GET", path, to: to, constraints: constraints, as: as, &block),
          add("HEAD", path, to: to, constraints: constraints, &block)
        ]
      end

      # Creates a route that match POST verb.
      #
      # @param path [String]
      # @param to [#call, String]
      # @param constraints [Hash]
      # @param &block [Proc]
      #
      # @return [Ramverk::Router::Route]
      def post(path, to: nil, constraints: {}, as: nil, &block)
        add "POST", path, to: to, constraints: constraints, as: as, &block
      end

      # Creates a route that match PUT verb.
      #
      # @param path [String]
      # @param to [#call, String]
      # @param constraints [Hash]
      # @param &block [Proc]
      #
      # @return [Ramverk::Router::Route]
      def put(path, to: nil, constraints: {}, as: nil, &block)
        add "PUT", path, to: to, constraints: constraints, as: as, &block
      end

      # Creates a route that match PATCH verb.
      #
      # @param path [String]
      # @param to [#call, String]
      # @param constraints [Hash]
      # @param &block [Proc]
      #
      # @return [Ramverk::Router::Route]
      def patch(path, to: nil, constraints: {}, as: nil, &block)
        add "PATCH", path, to: to, constraints: constraints, as: as, &block
      end

      # Creates a route that match DELETE verb.
      #
      # @param path [String]
      # @param to [#call, String]
      # @param constraints [Hash]
      # @param &block [Proc]
      #
      # @return [Ramverk::Router::Route]
      def delete(path, to: nil, constraints: {}, as: nil, &block)
        add "DELETE", path, to: to, constraints: constraints, as: as, &block
      end

      # Creates a route that match HEAD verb.
      #
      # @param path [String]
      # @param to [#call, String]
      # @param constraints [Hash]
      # @param &block [Proc]
      #
      # @return [Ramverk::Router::Route]
      def head(path, to: nil, constraints: {}, as: nil, &block)
        add "HEAD", path, to: to, constraints: constraints, as: as, &block
      end

      # Creates a route that match OPTIONS verb.
      #
      # @param path [String]
      # @param to [#call, String]
      # @param constraints [Hash]
      # @param &block [Proc]
      #
      # @return [Ramverk::Router::Route]
      def options(path, to: nil, constraints: {}, as: nil, &block)
        add "OPTIONS", path, to: to, constraints: constraints, as: as, &block
      end

      # Creates a route that match TRACE verb.
      #
      # @param path [String]
      # @param to [#call, String]
      # @param constraints [Hash]
      # @param &block [Proc]
      #
      # @return [Ramverk::Router::Route]
      def trace(path, to: nil, constraints: {}, as: nil, &block)
        add "TRACE", path, to: to, constraints: constraints, as: as, &block
      end
    end
  end
end
