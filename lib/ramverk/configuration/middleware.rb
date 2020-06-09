# frozen_string_literal: true

module Ramverk
  class Configuration
    # Middleware manager.
    class Middleware
      # Return all registered middleware in the stack.
      #
      # @return [Array]
      attr_reader :stack

      # @private
      def initialize
        @stack = []
      end

      # Append a middleware to the stack.
      #
      # @param middleware [Class]
      # @param *args [*]
      # @param &block [Proc]
      def append(middleware, *args, &block)
        @stack << [middleware, args, block].freeze
      end
      alias use append

      # Prepend a middleware to the stack.
      #
      # @param middleware [Class]
      # @param *args [*]
      # @param &block [Proc]
      def prepend(middleware, *args, &block)
        @stack.unshift [middleware, args, block].freeze
      end

      # @private
      def freeze
        @stack.freeze

        super
      end
    end
  end
end
