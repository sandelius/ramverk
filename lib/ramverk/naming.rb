# frozen_string_literal: true

module Ramverk
  # Conveniences for inflecting and working with names in Ramverk.
  module Naming
    module_function

    # Return a downcased and underscore separated version of the string.
    #
    # Revised version of `Hanami::Utils::String.underscore` implementation.
    #
    # @param string [String]
    #
    # @return [String]
    #
    # @example
    #   string = "Ramverk::RamverNaming"
    #   Ramverk::Naming.underscore(string) # => 'ramverk/ramverk_naming'
    def underscore(string)
      string = string.dup.to_s
      string.gsub!("::", "/")
      string.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
      string.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      string.gsub!(/[[:space:]]|\-/, '\1_\2')
      string.downcase!
      string
    end

    # Return a CamelCase version of the string.
    #
    # Revised version of `Hanami::Utils::String.classify` implementation.
    #
    # @param string [String]
    #
    # @return [String]
    #
    # @example
    #   string = "ramverk/ramverk_naming"
    #   Ramverk::Naming.classify(string) # => 'Ramverk::RamverNaming'
    def classify(string)
      words = underscore(string).split(%r{_|::|\/|\-}).map!(&:capitalize)
      delimiters = underscore(string).scan(%r{_|::|\/|\-})
      delimiters.map! { |delimiter| delimiter == "_" ? "" : "::" }
      words.zip(delimiters).join
    end
  end
end
