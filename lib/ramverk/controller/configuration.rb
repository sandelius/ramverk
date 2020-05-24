# frozen_string_literal: true

module Ramverk
  class Controller
    # Controller configuration.
    class Configuration
      # Default response format.
      #
      # @return [Symbol]
      attr_accessor :default_format

      # Default response headers.
      #
      # @return [Hash]
      attr_accessor :default_headers

      # @private
      def initialize
        reset
      end

      # @private
      def reset
        @default_format = :html
        @default_headers = {}
      end

      # @private
      def dup
        Configuration.new.tap do |c|
          c.default_format = default_format
          c.default_headers = default_headers.dup
        end
      end
    end
  end
end
