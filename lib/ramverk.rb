# frozen_string_literal: true

# The Ruby Application Framework.
module Ramverk
  require_relative "ramverk/version"
  require_relative "ramverk/application"

  # Get the current environment status.
  #
  # @return [Symbol]
  def self.env
    (ENV["APP_ENV"] || ENV["RACK_ENV"] || :development).to_sym
  end

  # Check if the given environment match the current.
  #
  # @overload env?(environment, ...)
  #   @param environment [Symbol]
  #   @param ... [Symbol]
  #
  # @return [Boolean]
  def self.env?(*environment)
    environment.include?(env)
  end

  # Returns the application.
  #
  # @return [Ramverk::Application]
  def self.application
    @application
  end

  # @private
  def self.application=(app)
    raise "an application has already been registered" if @application

    @application = app
  end

  # @private
  def self.reset
    Controller.configuration.reset

    @application = nil
  end
end
