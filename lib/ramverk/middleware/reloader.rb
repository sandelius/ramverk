# frozen_string_literal: true

module Ramverk
  module Middleware
    # Code reloader middleware.
    #
    # @private
    class Reloader
      # @private
      def initialize(app, loader)
        @app = app
        @loader = loader
      end

      # @private
      def call(env)
        @loader.reload

        @app.call(env)
      end
    end
  end
end
