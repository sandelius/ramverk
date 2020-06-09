# frozen_string_literal: true

module Ramverk
  class Router
    # Represenst a mounted route.
    class Mount < Route
      # @private
      def initialize(template, endpoint, constraints = {}, host: nil)
        @host = host

        super(template, endpoint, constraints)
      end

      # @see Ramverk::Router::Route#match?
      def match?(env)
        return false if @host && !@host.match?(extract_host(env))

        !!@pattern.peek(env["PATH_INFO"])
      end

      # @see Ramverk::Router::Route#params
      def params(path)
        @pattern.peek_params(path)&.first || {}
      end

      private

      # @private
      def extract_host(env)
        env["router.host"] ||= begin
          if (forwarded = env["HTTP_X_FORWARDED_HOST"])
            forwarded.split(/,\s?/).last
          else
            env["HTTP_HOST"] || env["SERVER_NAME"] || env["SERVER_ADDR"]
          end
        end
      end
    end
  end
end
