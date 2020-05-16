# frozen_string_literal: true

module Ramverk
  module Middleware
    # Code reloader middleware.
    #
    # @private
    class Reloader
      def initialize(app, loader)
        @app = app
        @loader = loader
      end

      def call(env)
        @loader.reload

        @app.call(env)
      end
    end
  end
end
