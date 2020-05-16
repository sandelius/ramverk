# frozen_string_literal: true

RSpec.describe "Request logging", type: :request do
  let :application do
    Class.new(Ramverk::Application) do
      set :logger, Logger.new($stdout)

      set :routes do
        get "/books", to: ->(_) { [200, {}, ["Hello"]] }
        get "/books/:id", to: ->(_) { [200, {}, ["Hello"]] }
      end
    end
  end

  def app
    application.new
  end

  it "log request information" do
    msg = Regexp.escape(%(GET[200] '/books' for 127.0.0.1 in))

    expect { get "/books" }
      .to output(/#{msg}/).to_stdout
  end

  it "filter out sensitive data" do
    msg = Regexp.escape(
      %(with {"id"=>"5", "session"=>{"password"=>"[FILTERED]"}})
    )

    expect { get "/books/5?session[password]=secret" }
      .to output(/#{msg}/).to_stdout
  end
end
