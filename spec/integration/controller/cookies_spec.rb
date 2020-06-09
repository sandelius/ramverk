# frozen_string_literal: true

class CookiesController < Ramverk::Controller
  def set
    cookies[:name] = "Tobias"
    render ""
  end

  def get
    render cookies[:name]
  end

  def delete
    cookies.delete(:name)
    render ""
  end
end

RSpec.describe "Ramverk::Controller#cookies", type: :request do
  let :application do
    Class.new(Ramverk::Application) do
      routes do
        get "/set", to: "CookiesController#set"
        get "/get", to: "CookiesController#get"
        get "/delete", to: "CookiesController#delete"
      end
    end
  end

  def app
    application.new
  end

  it "acts as a hash" do
    get "/set"

    expect(rack_mock_session.cookie_jar["name"])
      .to eq("Tobias")

    get "/get"
    expect(last_response.body)
      .to eq("Tobias")

    get "/delete"

    expect(rack_mock_session.cookie_jar["name"])
      .to eq("")
  end
end
