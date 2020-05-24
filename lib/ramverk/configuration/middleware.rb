# frozen_string_literal: true

require "rack"

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
      # @param middleware [Class] Middleware class.
      # @param *args [*] Middleware arguments.
      # @param &block [Proc] Middleware block argument.
      def append(middleware, *args, &block)
        @stack << [middleware, args, block].freeze
      end
      alias use append

      # Prepend a middleware to the stack.
      #
      # @param middleware [Class] Middleware class.
      # @param *args [*] Middleware arguments.
      # @param &block [Proc] Middleware block argument.
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
