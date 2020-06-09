# frozen_string_literal: true

require "json"

RSpec.describe "BodyParser middleware", type: :request do
  let :application do
    Class.new(Ramverk::Application) do
      config.logger = Logger.new($stdout)
      config.body_parsers = { json: ->(data) { JSON.parse(data) } }

      routes do
        post "/" do
          render "name: #{params['name']}"
        end

        post "/failure" do |_|
        end
      end
    end
  end

  def app
    application.new
  end

  it "parse json request" do
    application.config.logger = nil
    header "Content-Type", "application/json"

    post "/", '{"name":"Tobias"}'

    expect(last_response.body)
      .to eq("name: Tobias")
  end

  it "logs error on failure" do
    header "Content-Type", "application/json"

    expect { post "/failure", '{"name":"Tobias"' }
      .to output(/unexpected token at/).to_stdout_from_any_process

    expect(last_response.status)
      .to eq(400)
    expect(last_response.body)
      .to eq("invalid request data")
  end
end
