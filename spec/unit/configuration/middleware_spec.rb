# frozen_string_literal: true

module Ramverk
  RSpec.describe Configuration::Middleware do
    let(:middleware) { Configuration::Middleware.new }

    describe "#append" do
      it "appends a middleware to the stack" do
        middleware.append Rack::ETag
        middleware.append Rack::MethodOverride

        expect(middleware.stack.map(&:first))
          .to eq([Rack::ETag, Rack::MethodOverride])
      end

      it "has an alias in #use" do
        middleware.use Rack::ETag
        middleware.use Rack::MethodOverride

        expect(middleware.stack.map(&:first))
          .to eq([Rack::ETag, Rack::MethodOverride])
      end
    end

    describe "#prepend" do
      it "prepends a middleware to the stack" do
        middleware.use Rack::ETag
        middleware.prepend Rack::MethodOverride

        expect(middleware.stack.map(&:first))
          .to eq([Rack::MethodOverride, Rack::ETag])
      end
    end
  end
end
