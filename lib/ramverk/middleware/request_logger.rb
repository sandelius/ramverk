# frozen_string_literal: true

require "rack/common_logger"

module Ramverk
  module Middleware
    # Request logger based on `Rack::CommonLogger`.
    #
    # Each request will output in the following format:
    #
    #   GET[200] /books/5 from 120.0.0.1 in 0.0032 with {"id"=>"5"}
    class RequestLogger < Rack::CommonLogger
      # @private
      FORMAT = %(%<verb>s[%<status>s] '%<path>s' for %<ip>s in %<time>0.4f with %<params>s)

      # @private
      def initialize(app, logger, filter_params = [])
        @filter_params = filter_params

        super(app, logger)
      end

      private

      # @private
      # rubocop:disable Metrics/AbcSize
      def log(env, status, _, began_at)
        req = Rack::Request.new(env)
        params = (env["router.params"] || {}).merge(req.params)

        msg = format(FORMAT,
                     verb: req.request_method,
                     status: status.to_s[0..3],
                     path: req.path,
                     ip: req.ip,
                     time: Rack::Utils.clock_time - began_at,
                     params: params.empty? ? "{}" : filter(params))

        @logger.info(msg)
      end
      # rubocop:enable Metrics/AbcSize

      # @private
      def filter(params)
        filtered_params = params.dup

        filtered_params.each do |k, v|
          if v.is_a?(Hash)
            filtered_params[k] = filter(v)
          elsif @filter_params.include?(k)
            filtered_params[k] = "[FILTERED]"
          end
        end

        filtered_params
      end
    end
  end
end
