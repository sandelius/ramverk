# frozen_string_literal: true

require "rack/common_logger"

module Ramverk
  module Middleware
    # Request logger based on `Rack::CommonLogger`.
    class RequestLogger < Rack::CommonLogger
      # @private
      def initialize(app, logger, filter_params = [])
        @filter_params = filter_params

        super(app, logger)
      end
    end
  end
end
