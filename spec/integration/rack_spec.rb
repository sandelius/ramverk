# frozen_string_literal: true

RSpec.describe "Router Rack compatible", type: :request do
  let :application do
    Class.new(Ramverk::Application) do
      use Rack::ContentLength

      # This is here to check if the reloader is triggered. We can see that it
      # is from the coverage but it should be moved to its own spec.
      set :autoload_reload, true
      set :autoload_paths, %w[spec/tmp]

      set :routes do
        get "/say/:message", to: (lambda do |env|
          [200, {}, ["I say, #{env['rutter.params']['message']}"]]
        end)
      end
    end
  end

  def app
    application.new
  end

  context "with match" do
    it "calls the matched endpoint" do
      get "/say/hello-world"

      expect(last_response.status)
        .to eq(200)
      expect(last_response.body)
        .to eq("I say, hello-world")
      expect(last_response.headers["Content-Length"])
        .to eq("18")
    end
  end

  context "with no match" do
    it "returns 404" do
      get "/authors"

      expect(last_response.status)
        .to eq(404)
      expect(last_response.body)
        .to eq("Not Found")
      expect(last_response.headers["X-Cascade"])
        .to eq("pass")
    end
  end
end
