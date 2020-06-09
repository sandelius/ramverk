# frozen_string_literal: true

require "bundler/setup"
require_relative "../lib/ramverk"

# puma -e production -t 16:16
class Application < Ramverk::Application
  config.logger = nil

  routes do
    # wrk -t 2 http://localhost:9292/
    root do
      render "Hello World"
    end

    # wrk -t 2 http://localhost:9292/ruby
    get "/:lang" do
      render params["lang"]
    end
  end
end

run Application.new
