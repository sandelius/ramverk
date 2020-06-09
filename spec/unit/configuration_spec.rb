# frozen_string_literal: true

module Ramverk
  RSpec.describe Configuration do
    let(:configuration) { Configuration.new }

    describe "root" do
      it "is set to pwd by default" do
        expect(configuration.root)
          .to eq(Pathname.new(Dir.pwd))
      end

      it "raises an error if path does not exist" do
        expect { configuration.root = "invalid" }
          .to raise_error(Errno::ENOENT)
      end
    end

    describe "#middleware" do
      it "returns a middleware manager instance" do
        configuration.middleware.use Rack::Head

        expect(configuration.middleware.stack)
          .to eq([[Rack::Head, [], nil]])
      end
    end

    describe "#controller" do
      it "returns controller configuration" do
        expect(configuration.controller)
          .to be_a(Controller::Configuration)
      end
    end

    describe "#environment" do
      it "yields the block if the environment match" do
        configuration.environment :development do
          configuration.root = __dir__
        end

        expect(configuration.root)
          .to eq(Pathname.new(Dir.pwd))

        configuration.environment :test do
          configuration.root = __dir__
        end

        expect(configuration.root)
          .to eq(Pathname.new(__dir__))
      end
    end

    describe "logger" do
      context "level" do
        it "is set to :debug by default" do
          configuration = Configuration.new

          expect(configuration.logger_level)
            .to eq(:debug)
        end

        it "is set to :info in production" do
          configuration = Configuration.new(env: :production)

          expect(configuration.logger_level)
            .to eq(:info)
        end
      end

      context "formatter" do
        it "uses a default JSON formatter" do
          configuration = Configuration.new(env: :development)
          configuration.logger = Logger.new("spec/tmp/formatter.log")
          configuration.boot
          configuration.logger.debug "Hello World"

          data = File.read("spec/tmp/formatter.log").split("\n").last
          json = JSON.parse(data)

          expect(json["severity"])
            .to eq("DEBUG")
          expect(json["time"])
            .to match(/\d+/)
          expect(json["message"])
            .to eq("Hello World")
        end
      end
    end

    describe "autoloading" do
      context "autoload_eager_load" do
        it "is disbaled by default in development" do
          configuration = Configuration.new(env: :development)

          expect(configuration.autoload_eager_load)
            .to be(false)

          configuration = Configuration.new(env: :test)

          expect(configuration.autoload_eager_load)
            .to be(true)

          configuration = Configuration.new(env: :production)

          expect(configuration.autoload_eager_load)
            .to be(true)

          configuration = Configuration.new(env: :staging)

          expect(configuration.autoload_eager_load)
            .to be(true)
        end
      end

      context "autoload_reload" do
        it "is enabled by default in development" do
          configuration = Configuration.new(env: :development)

          expect(configuration.autoload_reload)
            .to be(true)

          configuration = Configuration.new(env: :production)

          expect(configuration.autoload_reload)
            .to be(false)

          configuration = Configuration.new(env: :test)

          expect(configuration.autoload_reload)
            .to be(false)
        end
      end
    end

    describe "dynamic configuration" do
      it "support settings dynamic configuration" do
        configuration.custom = Struct.new(:name).new

        expect(configuration.respond_to?(:custom))
          .to be(true)

        configuration.custom.name = "Tobias"

        expect(configuration.custom.name)
          .to eq("Tobias")
      end

      it "custom configuration id frozen upon boot" do
        configuration.custom = Struct.new(:name).new

        expect(configuration.custom)
          .not_to be_frozen

        configuration.boot

        expect(configuration.custom)
          .to be_frozen

        expect { configuration.custom2 = Struct.new(:name).new }
          .to raise_error(/modify frozen/)
      end
    end

    describe "#boot" do
      context "autoloading" do
        it "prepend a reloader middleware if reloading is enabled" do
          configuration.middleware.use Rack::Head
          configuration.autoload_paths += %w[spec/tmp]
          configuration.autoload_reload = true
          configuration.boot

          expect(configuration.middleware.stack.map(&:first))
            .to eq([Ramverk::Middleware::Reloader,
                    Ramverk::Middleware::RequestLogger,
                    Rack::Head])
        end
      end
    end
  end
end
