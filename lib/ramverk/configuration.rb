# frozen_string_literal: true

module Ramverk
  # Configuration object.
  class Configuration
    # Initializes the configuration object.
    #
    # @param &block [Proc]
    #   Block is evaluated inside the configuration object context.
    #
    # @private
    def initialize(&block)
      @settings = {}

      instance_eval(&block) if block_given?
    end

    # Check if key has been added.
    #
    # @param key [Symbol]
    #   Item identifier.
    #
    # @return [Boolean]
    def has?(key)
      settings.key?(key)
    end

    # Gets the value of the given key.
    #
    # @param key [Symbol]
    #   Item identifier.
    #
    # @return [*]
    def get(key)
      raise "':#{key}' has not been added" unless has?(key)

      settings[key]
    end
    alias [] get

    # Adds a new configuration item.
    #
    # @param key [Symbol]
    #   Item identifier.
    # @param default_value [*]
    #   Default item value.
    # @param &block [Proc]
    #   Store block Proc as default value.
    #
    # @return [self]
    def add(key, default_value = nil, &block)
      raise "':#{key}' has already been added" if has?(key)

      settings[key] = block || default_value

      self
    end

    # Updates an existing configuration item.
    #
    # @param key [Symbol]
    #   Item identifier.
    # @param value [*]
    #   Item value.
    # @param &block [Proc]
    #   Store block Proc as value.
    #
    # @return [self]
    def set(key, value = nil, &block)
      raise "':#{key}' has not been added" unless has?(key)

      settings[key] = block || value

      self
    end

    # Freeze the state of the configuration.
    #
    # @return [self]
    #
    # @private
    def freeze
      @settings.freeze

      super
    end

    private

    attr_reader :settings
  end
end
