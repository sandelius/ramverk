# frozen_string_literal: true

module Ramverk
  class Router
    # Represenst a scoped set of routes.
    #
    # @private
    class Scope
      # @private
      def initialize(router, path, namespace, name, &block)
        @_router = router
        @_path = path
        @_namespace = namespace
        @_name = name

        instance_eval(&block) if block_given?
      end

      # @private
      def root(to:, &block)
        get "/", to: to, as: :root, &block
      end

      # @private
      def scope(path = nil, namespace: nil, as: nil, &block)
        path = _join(@_path, path) if path
        namespace = _join(@_namespace, namespace)
        as = _join(@_name, as, separator: "_")

        Scope.new(@_router, path, namespace, as, &block)
      end

      # @private
      Router::VERBS.each do |verb|
        verb_method = verb.downcase
        define_method verb_method do |path, to: nil, as: nil, constraints: {}, &block|
          path = _join(@_path, path)
          to = _join(@_namespace, to) if to.is_a?(String)
          as = _join(@_name, as, separator: "_") if as

          @_router.send verb_method, path, to: to, as: as, constraints: constraints, &block
        end
      end

      private

      # @private
      def _join(*args, separator: "/")
        args.reject { |s| s.nil? || s == "" }.join(separator)
      end
    end
  end
end
