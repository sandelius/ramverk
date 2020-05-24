# frozen_string_literal: true

# puma -e production -t 16:16

require "bundler/setup"
require_relative "../lib/ramverk"

class Controller < Ramverk::Controller
  def hello
    render "Helllo World"
  end

  def lang
    render params["lang"]
  end
end

class Application < Ramverk::Application
  config.logger = false

  routes do
    # wrk -t 2 http://localhost:9292/
    get "/", to: "controller#hello"

    # wrk -t 2 http://localhost:9292/ruby
    get "/:lang", to: "controller#lang"
  end
end

run Application.new
