# frozen_string_literal: true

RSpec::Matchers.define :be_a_file do
  match { |actual| File.exist?(actual) }
  description { "be an existing file" }
end

RSpec::Matchers.define :include_text do |expected|
  match { |actual| File.read(actual).include?(expected) }
  description { "include the text" }
end
