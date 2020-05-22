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

      # Prepend a middleware, before the specified, to the stack.
      #
      # @param lookup [Class] Lookup middleware.
      # @param middleware [Class] Middleware class.
      # @param *args [*] Middleware arguments.
      # @param &block [Proc] Middleware block argument.
      #
      # @raise [RuntimeError] If the specified middleware is not found.
      def before(lookup, middleware, *args, &block)
        mw_index = index(lookup)

        raise "#{lookup.name} could not be found in stack" unless mw_index

        @stack.insert(mw_index, [middleware, args, block].freeze)
      end

      # Append a middleware, before the specified, to the stack.
      #
      # @param lookup [Class] Lookup middleware.
      # @param middleware [Class] Middleware class.
      # @param *args [*] Middleware arguments.
      # @param &block [Proc] Middleware block argument.
      #
      # @raise [RuntimeError] If the specified middleware is not found.
      def after(lookup, middleware, *args, &block)
        mw_index = index(lookup)

        raise "#{lookup.name} could not be found in stack" unless mw_index

        @stack.insert(mw_index + 1, [middleware, args, block].freeze)
      end

      # Gets the stack index for the given middleware.
      #
      # If the middleware is not found in stack `nil` is returned.
      #
      # @param middleware [Class] Middleware to lookup.
      #
      # @return [Integer, nil]
      def index(middleware)
        @stack.index { |(mw, _, _)| mw == middleware }
      end

      # @private
      def freeze
        @stack.freeze

        super
      end
    end
  end
end
