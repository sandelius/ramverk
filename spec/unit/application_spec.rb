# frozen_string_literal: true

module Ramverk
  RSpec.describe Application do
    let(:app) { Class.new(Application) }

    it "adds 'app' as an alias for self" do
      expect(app)
        .to eq(app.app)
    end

    context "configuration" do
      it "adds alias for managing configuration" do
        expect(app.configuration).to receive(:add)
        app.add :name, "Tobias"

        expect(app.configuration).to receive(:set)
        app.set :name, "Sandelius"
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
    end

    describe ".use" do
      it "append middleware to the stack" do
        app.use Rack::Head
        app.use Rack::Static, root: "public", urls: %w[/assets]

        expect(app.configuration[:_middleware].map(&:first))
          .to eq([Rack::Head, Rack::Static])
      end
    end

    describe ".env" do
      it "yields the block if the environment match" do
        app.use Rack::Head

        app.env :development do
          app.use Rack::Static, root: "public", urls: %w[/assets]
        end

        app.env :test do
          app.use Rack::ConditionalGet
        end

        expect(app.configuration[:_middleware].map(&:first))
          .to eq([Rack::Head, Rack::ConditionalGet])
      end
    end

    describe ".boot" do
      context "autoload" do
        it "prepend a reloader middleware if reloading is enabled" do
          app.use Rack::Head
          app.set :autoload_paths, %w[spec/tmp]
          app.set :autoload_reload, true
          app.boot

          expect(app.configuration[:_middleware].map(&:first))
            .to eq([Ramverk::Middleware::Reloader,
                    Ramverk::Middleware::RequestLogger,
                    Rack::Head])
        end
      end

      context "logger" do
        it "prepends a request logger" do
          app.boot

          expect(app.configuration[:_middleware].map(&:first))
            .to eq([Ramverk::Middleware::RequestLogger])
        end

        it "skip request logger if logging is disabled" do
          app.set :logger, nil
          app.boot

          expect(app.configuration[:_middleware].map(&:first))
            .to eq([])
        end
      end

      context "events" do
        it "execute the callbacks on events" do
          data = []

          app.run :post_boot do |application|
            expect(app)
              .to eq(application)

            data << :post_boot
          end

          app.run :pre_boot do |application|
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

          expect { app.run(:unknown) {} }
            .to raise_error(NameError, msg)
        end
      end
    end
  end
end
