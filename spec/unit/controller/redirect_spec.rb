# frozen_string_literal: true

module Ramverk
  RSpec.describe Controller do
    let(:controller) do
      Class.new(Controller) do
        def redirect_with_default_status
          redirect "/new/location"
        end

        def redirect_with_custom_status
          redirect "/new/location", status: 301
        end
      end
    end

    describe "#redirect" do
      it "sets location header with a default status" do
        status, headers, = controller.new(:redirect_with_default_status).call({})

        expect(status)
          .to eq(302)
        expect(headers["Location"])
          .to eq("/new/location")
      end

      it "allows status to be set" do
        status, headers, = controller.new(:redirect_with_custom_status).call({})

        expect(status)
          .to eq(301)
        expect(headers["Location"])
          .to eq("/new/location")
      end
    end
  end
end
