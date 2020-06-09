# frozen_string_literal: true

module Ramverk
  class Router
    # @private
    class Scope
      include Methods

      # @private
      def initialize(router, path, namespace, as, &block)
        @_router = router
        @_path = path
        @_namespace = namespace
        @_as = as

        instance_eval(&block) if block_given?
      end

      # @private
      def scope(path = nil, namespace: nil, as: nil, &block)
        path = File.join(@_path, path) if @_path
        namespace = "#{@_namespace}::#{namespace}" if @_namespace
        as = "#{@_as}_#{as}" if @_as

        Scope.new(@_router, path, namespace, as, &block)
      end

      # @private
      # rubocop:disable Metrics/ParameterLists
      def add(verb, path, to: nil, constraints: {}, as: nil, &block)
        path = File.join(@_path, path) if @_path
        to = "#{@_namespace}::#{to}" if @_namespace && to.is_a?(String)
        as = "#{@_as}_#{as}" if @_as && as

        @_router.add verb, path, to: to, constraints: constraints, as: as, &block
      end
      # rubocop:enable Metrics/ParameterLists
    end
  end
end
