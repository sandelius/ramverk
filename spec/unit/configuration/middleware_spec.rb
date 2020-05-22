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

    describe "#before" do
      it "prepends the middleware before the lookup" do
        middleware.use Rack::ETag
        middleware.use Rack::MethodOverride

        middleware.before Rack::MethodOverride, Rack::ContentType

        expect(middleware.stack.map(&:first))
          .to eq([Rack::ETag, Rack::ContentType, Rack::MethodOverride])
      end

      it "raises an error if lookup is not found" do
        middleware.use Rack::ETag

        expect { middleware.before Rack::MethodOverride, Rack::ContentType }
          .to raise_error(RuntimeError,
                          "Rack::MethodOverride could not be found in stack")
      end
    end

    describe "#after" do
      it "prepends the middleware before the lookup" do
        middleware.use Rack::ETag
        middleware.use Rack::MethodOverride

        middleware.after Rack::ETag, Rack::ContentType

        expect(middleware.stack.map(&:first))
          .to eq([Rack::ETag, Rack::ContentType, Rack::MethodOverride])
      end

      it "raises an error if lookup is not found" do
        middleware.use Rack::ETag

        expect { middleware.after Rack::MethodOverride, Rack::ContentType }
          .to raise_error(RuntimeError,
                          "Rack::MethodOverride could not be found in stack")
      end
    end
  end
end
