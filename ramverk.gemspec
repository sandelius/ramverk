# frozen_string_literal: true

require File.expand_path("lib/ramverk/version", __dir__)

Gem::Specification.new do |spec|
  spec.name = "ramverk"
  spec.version = Ramverk::VERSION
  spec.summary = "The Ruby Application Framework."

  spec.required_ruby_version = ">= 2.5.0"

  spec.license = "MIT"

  spec.author = "Tobias Sandelius"
  spec.email = "tobias@sandeli.us"
  spec.homepage = "https://github.com/sandelius/ramverk"

  spec.files = `git ls-files -z`.split("\x0")
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "thor", "~> 1.0"
  spec.add_runtime_dependency "rack", "~> 2.0"
  spec.add_runtime_dependency "zeitwerk", "~> 2.3"
  spec.add_runtime_dependency "mustermann", "~> 1.1"
  spec.add_runtime_dependency "tilt", "~> 2.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rack-test"
end
