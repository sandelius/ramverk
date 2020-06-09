# frozen_string_literal: true

RSpec::Matchers.define :be_a_file do
  match { |actual| File.exist?(actual) }
  description { "be an existing file" }
end
