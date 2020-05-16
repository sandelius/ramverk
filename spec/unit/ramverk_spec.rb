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
end
