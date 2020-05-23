# frozen_string_literal: true

module Ramverk
  RSpec.describe Router do
    let(:router) { Router.new }
    let(:endpoint) { ->(_) {} }

    it "support nested scopes" do
      router.scope "animals", namespace: "species", as: :animals do
        scope "mammals", namespace: "mammals", as: :mammals do
          get "/cats", to: "cats#index", as: :cats
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

    describe "verbs" do
      let(:scope) { router.scope }

      Router::VERBS.each do |verb|
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
