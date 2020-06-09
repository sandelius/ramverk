# frozen_string_literal: true

module Ramverk
  class Controller
    # Hash like wrapper for Rack::Response cookie management.
    class Cookies
      # @private
      def initialize(response, previous: {})
        @cookies = previous.dup
        @response = response
      end

      # Set a cookie.
      #
      # @param key [String]
      #   Cookie identifier.
      # @param value [String, Hash]
      #   Cookie value.
      def []=(key, value)
        key = key.to_s
        @response.set_cookie(key, value)
        @cookies[key] = value.is_a?(Hash) ? value[:value] : value
      end

      # Get a cookie.
      #
      # @param key [String]
      #   Cookie identifier.
      #
      # @return [*, nil]
      #   If cookie key is not found, `nil` is returned.
      def [](key)
        @cookies[key.to_s]
      end

      # Delete a cookie.
      #
      # @param key [String]
      #   Cookie identifier.
      def delete(key, value = {})
        key = key.to_s
        @response.delete_cookie(key, value)
        @cookies.delete(key)
      end
    end
  end
end
