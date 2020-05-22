# frozen_string_literal: true

require "ramverk/cli/command"

module RSpec
  module Support
    module Cli
      module_function

      def ramverk(*args)
        Ramverk::Cli::Command.start(args)
      end
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::Support::Cli, type: :cli
end
