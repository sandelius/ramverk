# frozen_string_literal: true

require "fileutils"

module RSpec
  module Support
    module Cleaner
      def clean_tmp
        tmp = File.expand_path("../tmp", __dir__)

        FileUtils.rm_rf(tmp)
        FileUtils.mkdir(tmp)
      end
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::Support::Cleaner

  config.before :each do
    # Clear all constant loaders
    Zeitwerk::Registry.loaders.clear

    # Clean tmp directory
    clean_tmp

    # Reset framework
    Ramverk.reset
  end
end
