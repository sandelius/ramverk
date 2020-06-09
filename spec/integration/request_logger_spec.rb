# frozen_string_literal: true

RSpec.describe "Request logging", type: :request do
  let :application do
    Class.new(Ramverk::Application) do
      config.logger = Logger.new($stdout)

      routes do
        get "/books", to: ->(_) { [200, {}, []] }
        get "/books/:id", to: ->(_) { [200, {}, []] }
      end
    end
  end

  def app
    application.new
  end

  it "log request information" do
    msg = Regexp.escape(%([200] GET '/books' for 127.0.0.1 in))

    expect { get "/books" }
      .to output(/#{msg}/).to_stdout
  end

  it "filter out sensitive data" do
    application.config.logger = Logger.new("spec/tmp/formatter.log")

    get "/books/5?session[password]=secret"

    data = File.read("spec/tmp/formatter.log").split("\n").last
    message = JSON.parse(data)["message"]

    expect(message)
      .to include(%(with {"id"=>"5", "session"=>{"password"=>"[FILTERED]"}}))
  end
end
