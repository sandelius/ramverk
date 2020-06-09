# frozen_string_literal: true

module Ramverk
  class Router
    RSpec.describe Mount do
      let(:endpoint) { ->(_) {} }

      describe "#match?" do
        it "returns true if path prefix match" do
          route = Mount.new("/books", endpoint)

          expect(route.match?(env_for("/books")))
            .to be(true)
          expect(route.match?(env_for("/books/5/reviews")))
            .to be(true)
          expect(route.match?(env_for("/reviews")))
            .to be(false)
        end

        it "support matching via host" do
          route = Mount.new("/books", endpoint, {}, host: /\Aapi\./)

          expect(route.match?(env_for("https://example.com/books")))
            .to be(false)
          expect(route.match?(env_for("https://api.example.com/books")))
            .to be(true)
        end

        it "supports HTTP_X_FORWARDED_HOST" do
          route = Mount.new("/v1", endpoint, {}, host: /\Aapi\./)

          env = env_for("/v1/books", "HTTP_X_FORWARDED_HOST" => "api.example.com")

          expect(route.match?(env))
            .to be(true)
        end
      end

      describe "#params" do
        it "extract params" do
          route = Mount.new("/pages/:id", endpoint)

          expect(route.params("/pages/54/eloquent-ruby"))
            .to eq("id" => "54")
          expect(route.params("/pages/54"))
            .to eq("id" => "54")
          expect(route.params("/pages"))
            .to eq({})
        end
      end
    end
  end
end
