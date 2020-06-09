# frozen_string_literal: true

require "rack/test"

module RSpec
  module Support
    module Rack
      module_function

      def env_for(uri = "", opts = {})
        ::Rack::MockRequest.env_for(uri, opts)
      end
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::Support::Rack
  config.include Rack::Test::Methods, type: :request
end
