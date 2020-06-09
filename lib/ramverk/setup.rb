# frozen_string_literal: true

require "ramverk"

# rubocop:disable Lint/SuppressedException

begin
  require "dotenv"
  Dotenv.load(".env.#{Ramverk.env}")
rescue LoadError
end

begin
  require "rspec"
  require "rack/test"

  RSpec.configure do |config|
    config.include Rack::Test::Methods, type: :request

    def app
      Ramverk.application.new
    end
  end

  if Ramverk.rake?
    require "rspec/core/rake_task"
    RSpec::Core::RakeTask.new(:spec)
  end
rescue LoadError
end

# rubocop:enable Lint/SuppressedException
