# frozen_string_literal: true

RSpec.describe "ramverk version", type: :cli do
  it "prints the current framework version" do
    expect { ramverk "version" }
      .to output("#{Ramverk::VERSION}\n").to_stdout
  end
end
