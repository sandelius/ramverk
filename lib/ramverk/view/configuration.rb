# frozen_string_literal: true

require_relative "cache"

module Ramverk
  class View
    # View configuration.
    class Configuration
      # Default layout.
      #
      # @return [String, FalseClass]
      attr_accessor :default_layout

      # Paths to templates.
      #
      # @return [Hash]
      attr_accessor :template_paths

      # Cache templates.
      #
      # @return [Booleab]
      attr_accessor :cache_templates

      # Cache object.
      #
      # @return [#fetch]
      attr_accessor :cache

      # @private
      def initialize
        reset
      end

      # @private
      def reset
        @default_layout = "application.erb"
        @template_paths = []
        @cache_templates = !Rails.env?(:development)
        @cache = Cache.new
      end

      # @private
      def dup
        Configuration.new.tap do |c|
          c.default_layout = default_layout
          c.template_paths = template_paths.dup
          c.cache_templates = cache_templates
          c.cache = cache
        end
      end
    end
  end
end
