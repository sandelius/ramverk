# frozen_string_literal: true

module Ramverk
  RSpec.describe Controller do
    let(:controller) { Class.new(Controller).new(:index) }

    describe "#render" do
      it "raise s an error if :as (content type is unkown)" do
        expect { controller.render("Hello World", as: :invalid) }
          .to raise_error("unkown content type ':invalid'")
      end
    end
  end
end
