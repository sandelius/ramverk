# frozen_string_literal: true

module Ramverk
  module Middleware
    # Requets body parser.
    #
    # @private
    class BodyParser
      # @private
      def initialize(app, parsers: {}, logger: nil)
        @app = app
        @parsers = parsers
        @logger = logger
      end

      # @private
      def call(env)
        content_type = env["CONTENT_TYPE"]

        begin
          @parsers.each do |key, parser|
            next unless content_type.include?(key.to_s)
            parse(env, parser)
            break
          end
        rescue StandardError => e
          @logger&.warn "[Ramverk::Middleware::BodyParser] #{e.message}"
          return [400, {}, ["invalid request data"]]
        end

        @app.call(env)
      end

      private

      # @private
      def parse(env, parser)
        body = env["rack.input"].read
        return if body.empty?
        env["rack.input"].rewind
        parsed = parser.call(body)
        return unless parsed.is_a?(Hash)
        env.update "rack.request.form_hash" => parsed, "rack.request.form_input" => env["rack.input"]
      end
    end
  end
end
