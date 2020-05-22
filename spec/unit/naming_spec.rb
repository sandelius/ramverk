# frozen_string_literal: true

require "ramverk/naming"

module Ramverk
  RSpec.describe Naming do
    describe ".underscore" do
      it "makes a snake_cased version of a string" do
        expect(Naming.underscore("Web::Controllers::PostComments"))
          .to eq("web/controllers/post_comments")
      end
    end

    describe ".classify" do
      it "makes a CamelCase version of a string" do
        expect(Naming.classify("web/controllers/post_comments"))
          .to eq("Web::Controllers::PostComments")
      end
    end
  end
end
