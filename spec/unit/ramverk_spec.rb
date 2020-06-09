# frozen_string_literal: true

RSpec.describe Ramverk do
  it "has a version number" do
    expect(Ramverk::VERSION)
      .to be_a(String)
  end

  describe ".env" do
    it "return the current environment status" do
      expect(Ramverk.env)
        .to eq(:test)
    end
  end

  describe ".env?" do
    it "returns true if environment(s) match" do
      expect(Ramverk.env?(:test))
        .to be(true)
      expect(Ramverk.env?(:development, :test))
        .to be(true)
      expect(Ramverk.env?(:development))
        .to be(false)
      expect(Ramverk.env?(:staging, :production))
        .to be(false)
    end
  end

  describe ".rake?" do
    it "returns false if not run by rake" do
      expect(Ramverk.rake?)
        .to be(false)
    end

    it "returns true if run by rake" do
      previous_program = $PROGRAM_NAME
      $PROGRAM_NAME = "/path/to/rake"

      expect(Ramverk.rake?)
        .to be(true)

      $PROGRAM_NAME = previous_program
    end
  end

  describe ".application" do
    it "returns the active application" do
      app = Class.new(Ramverk::Application)

      expect(Ramverk.application)
        .to eq(app)
    end

    it "raises an error if an application already been registered" do
      Class.new(Ramverk::Application)

      expect { Class.new(Ramverk::Application) }
        .to raise_error("an application has already been registered")
    end

    it "evaluats a given block inside the application class context" do
      app = Class.new(Ramverk::Application)
      ctx = nil
      Ramverk.application { ctx = self }

      expect(ctx)
        .to eq(app)
    end
  end
end
