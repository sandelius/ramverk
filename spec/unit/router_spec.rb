# frozen_string_literal: true

module Ramverk
  RSpec.describe Router do
    let(:router) { Router.new }
    let(:endpoint) { ->(_) {} }

    describe "#add" do
      it "support using route constraints" do
        route = router.get "/books/:id",
                           to: endpoint,
                           constraints: { id: /\d+/ }

        expect(route.match?(env_for("/books/82")))
          .to be(true)
        expect(route.match?(env_for("/books/pickaxe")))
          .to be(false)
      end

      it "support block as endpoint" do
        router.get "/" do |env|
          [200, {}, [env["message"]]]
        end

        _, _, body = router.call("REQUEST_METHOD" => "GET",
                                 "PATH_INFO" => "/",
                                 "message" => "Hello World")

        expect(body.join)
          .to eq("Hello World")
      end
    end

    describe "verbs" do
      Router::VERBS.each do |verb|
        describe "##{verb.downcase}" do
          it "recognize #{verb} verb" do
            route = router.public_send verb.downcase, "/", to: endpoint

            expect(router.verb_map[verb])
              .to eq([route])
          end
        end
      end
    end

    describe "#freeze" do
      it "freezes the router and its maps" do
        router.freeze

        expect(router)
          .to be_frozen
        expect(router.flat_map)
          .to be_frozen
        expect(router.verb_map)
          .to be_frozen
      end
    end
  end
end