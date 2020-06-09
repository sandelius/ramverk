# frozen_string_literal: true

module Ramverk
  RSpec.describe Controller do
    let(:parent_controller) { Class.new(Controller) }
    let(:controller) { Class.new(parent_controller) }

    it "has a configuration object set" do
      expect(Controller.configuration)
        .to be_a(Controller::Configuration)

      expect(parent_controller.configuration)
        .to be_a(Controller::Configuration)
      expect(parent_controller.configuration)
        .not_to eq(Controller.configuration)

      expect(controller.configuration)
        .to be_a(Controller::Configuration)
      expect(controller.configuration)
        .not_to eq(parent_controller.configuration)
    end

    it "duplicates configuration on inherit" do
      Controller.configuration.default_headers = { "Foo" => "Bar" }
      parent_controller.configuration.default_headers["Baz"] = "Qux"

      expect(Controller.configuration.default_headers)
        .to eq("Foo" => "Bar")
      expect(parent_controller.configuration.default_headers)
        .to eq("Foo" => "Bar", "Baz" => "Qux")
    end

    it "uses configuration" do
      Controller.configuration.default_headers = { "Foo" => "Bar" }
      controller.configuration.default_headers["Baz"] = "Qux"

      controller.class_eval do
        def index
          render headers.inspect
        end
      end

      _, headers, = controller.new(:index).call({})

      expect(headers["Foo"])
        .to eq("Bar")
      expect(headers["baz"])
        .to eq("Qux")
    end

    it "sets sensible default headers" do
      expect(controller.configuration.default_headers)
        .to eq("X-Content-Type-Options" => "nosniff",
               "X-Frame-Options" => "SAMEORIGIN",
               "X-XSS-Protection" => "1; mode=block")
    end
  end
end
