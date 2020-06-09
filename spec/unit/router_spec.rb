# frozen_string_literal: true

module Ramverk
  RSpec.describe Router do
    let(:router) { Router.new }
    let(:endpoint) { ->(_) {} }

    describe "#mount" do
      it "matches path prefixes" do
        route = router.mount endpoint, at: "/admin"

        expect(route.match?(env_for("/")))
          .to be(false)
        expect(route.match?(env_for("/books")))
          .to be(false)
        expect(route.match?(env_for("/admin")))
          .to be(true)
        expect(route.match?(env_for("/admin/books")))
          .to be(true)
      end

      it "matches host if given" do
        route = router.mount endpoint, at: "/v1", host: /\Aapi\./

        expect(route.match?(env_for("http://example.com/v1/books")))
          .to be(false)
        expect(route.match?(env_for("http://api.example.com/v1/books")))
          .to be(true)
      end
    end

    describe "#root" do
      it "adds a GET route for the root path (/)" do
        route, = router.root to: endpoint

        expect(route.template)
          .to eq("/")
        expect(router.verb_map["GET"])
          .to eq([route])
        expect(router.named_map[:root])
          .to eq(route)
      end
    end

    it "raises an error on duplicate route names" do
      router.get "/", to: endpoint, as: :books

      expect { router.get "/books", to: endpoint, as: :books }
        .to raise_error("duplicate route name ':books'")
    end

    describe "verbs" do
      describe "#GET" do
        it "creates both a GET and a HEAD route" do
          get_route, head_route = router.get "/", to: endpoint

          expect(router.verb_map["GET"])
            .to eq([get_route])
          expect(router.verb_map["HEAD"])
            .to eq([head_route])
        end
      end

      (Router::VERBS - ["GET"]).each do |verb|
        describe "##{verb.downcase}" do
          it "recognize #{verb} verb" do
            route = router.public_send verb.downcase, "/", to: endpoint

            expect(router.verb_map[verb])
              .to eq([route])
          end
        end
      end
    end
  end
end
