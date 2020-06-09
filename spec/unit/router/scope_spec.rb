# frozen_string_literal: true

module Ramverk
  RSpec.describe Router::Scope do
    let(:router) { Router.new }
    let(:endpoint) { ->(_) {} }

    it "support nested scopes" do
      router.scope "animals", namespace: "Species", as: :animals do
        scope "mammals", namespace: "Mammals", as: :mammals do
          get "/cats", to: "Cats#index", as: :cats
        end
      end

      route = router.flat_map.first

      expect(route.template)
        .to eq("/animals/mammals/cats")
      expect(route.endpoint)
        .to eq(controller: "Species::Mammals::Cats", action: "index")
      expect(router.named_map[:animals_mammals_cats])
        .to eq(route)
    end

    describe "#add" do
      it "support using route constraints" do
        scope = router.scope "/books"
        route, = scope.get "/:id",
                           to: endpoint,
                           constraints: { id: /\d+/ }

        expect(route.match?(env_for("/books/82")))
          .to be(true)
        expect(route.match?(env_for("/books/pickaxe")))
          .to be(false)
      end
    end

    describe "verbs" do
      let(:scope) { router.scope }

      (Router::VERBS - %w[GET]).each do |verb|
        describe "##{verb.downcase}" do
          it "recognize #{verb} verb" do
            route = scope.public_send verb.downcase, "/", to: endpoint

            expect(router.verb_map[verb])
              .to eq([route])
          end
        end
      end
    end
  end
end
