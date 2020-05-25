# frozen_string_literal: true

require "thread"

module Ramverk
  class View
    # View cache.
    #
    # @private
    class Cache
      # @private
      def initialize
        @mutex = Mutex.new
        @cache = {}
      end

      # @private
      def fetch(key, &block)
        @mutex.synchronize do
          @cache.fetch(key) { @cache[key] = yield }
        end
      end
    end
  end
end
