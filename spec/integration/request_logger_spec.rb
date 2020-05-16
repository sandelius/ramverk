# frozen_string_literal: true

RSpec.describe "Request logging", type: :request do
  let :application do
    Class.new(Ramverk::Application) do
      app[:logger] = Logger.new($stdout)

      set :routes do
        get "/", to: (lambda do |env|
          [200, {}, ["Hello"]]
        end)
      end
    end
  end

  def app
    application.new
  end

  it "log request information" do
    expect { get "/" }
      .to output(/GET \//).to_stdout
  end
end
