# frozen_string_literal: true

module Ramverk
  RSpec.describe Configuration do
    let(:configuration) { Configuration.new }

    describe "#get" do
      it "raises an error if key has not been added" do
        expect { configuration[:name] }
          .to raise_error("':name' has not been added")
      end
    end

    describe "#add" do
      it "adds a new item" do
        configuration.add :name, "Tobias"

        expect(configuration.get(:name))
          .to eq("Tobias")
      end

      it "use the block as value if given" do
        configuration.add :name do
          "Tobias"
        end

        expect(configuration.get(:name).call)
          .to eq("Tobias")
      end

      it "raises an error if item already been added" do
        configuration.add :name, "Tobias"

        expect { configuration.add :name, "Tobias" }
          .to raise_error("':name' has already been added")
      end
    end

    describe "#set" do
      it "updates an existing item" do
        configuration.add :name, "Tobias"
        configuration.set :name, "Sandelius"

        expect(configuration.get(:name))
          .to eq("Sandelius")
      end

      it "use the block as value if given" do
        configuration.add :name, "Tobias"
        configuration.set :name do
          "Sandelius"
        end

        expect(configuration.get(:name).call)
          .to eq("Sandelius")
      end

      it "raises an error if item has not been added" do
        expect { configuration.set :name, "Sandelius" }
          .to raise_error("':name' has not been added")
      end
    end

    describe "#freeze" do
      it "freezes all settings" do
        configuration.freeze

        expect { configuration.add :name, "Tobias" }
          .to raise_error(/frozen/)
      end
    end
  end
end
