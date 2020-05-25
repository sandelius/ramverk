# frozen_string_literal: true

require "tilt"

module Ramverk
  # The View is responsible for rendering templates and acs as context for
  # rendered templates.
  class View
    require_relative "controller/configuration"

    # @private
    def self.inherited(base)
      super

      base.configuration = configuration&.dup
    end

    # @private
    @configuration = Configuration.new

    class << self
      # Controller configuration.
      #
      # @return [Ramverk::Controller::Configuration]
      attr_accessor :configuration

      alias config configuration

      def render(template, layout: nil, locals: {})
        context = new(locals)
        template = read(template)
        template_output = template.render(context, locals)

        layout = configuration.default_layout if layout.nil?

        return template_output unless layout

        read("layouts/#{layout}").render(context, locals) { template_output }
      end

      # @private
      def read(template)
        return locate(template) unless configuration.cache_templates

        configuration.cache.fetch(template) { locate(template) }
      end

      # @private
      def locate(template)
        configuration.template_paths.each do |path|
          file = File.join(path, template)
          return Tilt.new(template) if File.exist?(file)
        end

        raise "missing template: '#{template}'"
      end
    end

    # @private
    def initialize(locals)
      @_locals = locals
    end

    def locals
      @_locals
    end

    def render(template, locals = {})
      self.class.read(template).render(self, locals)
    end
  end
end
