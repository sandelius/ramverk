# frozen_string_literal: true

module Ramverk
  RSpec.describe Controller do
    let(:parent_controller) { Class.new(Controller) }
    let(:controller) { Class.new(parent_controller) }

    it "inherit parent filters" do
      parent = Class.new(Controller) do
        before :one, :two
      end

      controller = Class.new(parent) do
        before :three
      end

      expect(controller._filters)
        .to eq(%i[one two three])
      expect(parent._filters)
        .to eq(%i[one two])
    end

    it "allows filters to be skipped" do
      parent = Class.new(Controller) do
        before :one, :two
      end

      controller = Class.new(parent) do
        skip_before :two
        before :three
      end

      expect(controller._filters)
        .to eq(%i[one three])
      expect(parent._filters)
        .to eq(%i[one two])
    end

    it "can halt the response" do
      controller = Class.new(Controller) do
        before :say_hello_world

        def say_hello_world
          render "Hello World"
        end

        def index
          render "Hello Index"
        end
      end

      _, _, body = controller.new(:index).call({})

      expect(body.join)
        .to eq("Hello World")
    end
  end
end
