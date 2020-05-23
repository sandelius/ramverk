# frozen_string_literal: true

module Ramverk
  class Router
    RSpec.describe Route do
      let(:endpoint) { ->(_) {} }

      it "freezes the object" do
        route = Route.new("/", endpoint)

        expect(route)
          .to be_frozen
        expect(route.endpoint)
          .to be_frozen
      end

      it "transorm string endpoint into Controller#action" do
        route = Route.new("/", "admin/pages#index")

        expect(route.endpoint)
          .to eq(controller: "Admin::Pages", action: "index")
      end

      describe "#match?" do
        it "returns true if path match" do
          route = Route.new("/books", endpoint)

          expect(route.match?(env_for("/books")))
            .to be(true)
        end

        it "returns false if path does not match" do
          route = Route.new("/books", endpoint)

          expect(route.match?(env_for("/")))
            .to be(false)
        end

        it "support using route constraints" do
          route = Route.new("/books/:id", endpoint, id: /\d+/)

          expect(route.match?(env_for("/books/82")))
            .to be(true)
          expect(route.match?(env_for("/books/pickaxe")))
            .to be(false)
        end
      end

      describe "#params" do
        it "extract params" do
          route = Route.new("/pages/:id(/:title)?", endpoint)

          expect(route.params("/pages/54/eloquent-ruby"))
            .to eq("id" => "54", "title" => "eloquent-ruby")
          expect(route.params("/pages/54"))
            .to eq("id" => "54", "title" => nil)
        end
      end
    end
  end
end
