# frozen_string_literal: true

module Ramverk
  RSpec.describe Application do
    let(:app) { Class.new(Application) }

    describe ".configuration" do
      it "returns application configuration" do
        expect(app.configuration)
          .to be_a(Configuration)
      end
    end

    context "container" do
      it "adds alias for accessing the container" do
        app[:name] = "Tobias"

        expect(app[:name])
          .to eq("Tobias")
      end

      it "raises a KeyError if item not been registered" do
        expect { app[:name] }
          .to raise_error(KeyError)
      end

      it "is freezes after boot" do
        app.boot

        expect { app[:name] = "Tobias" }
          .to raise_error(/modify frozen/)
      end
    end

    describe ".boot" do
      context "events" do
        it "execute registered callbacks on events" do
          data = []

          app.on :post_boot do |application|
            expect(app)
              .to eq(application)

            data << :post_boot
          end

          app.on :pre_boot do |application|
            expect(app)
              .to eq(application)

            data << :pre_boot
          end

          expect(data)
            .to be_empty

          app.boot

          expect(data)
            .to eq(%i[pre_boot post_boot])
        end

        it "raises an error if event name is unknown" do
          msg = "unknown event ':unknown'"

          expect { app.on(:unknown) {} }
            .to raise_error(msg)
        end
      end
    end
  end
end
