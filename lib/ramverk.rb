# frozen_string_literal: true

# Ramverk is a web application framework written in Ruby.
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

  # Check if the program is running via Rake.
  #
  # @return [Boolean]
  def self.rake?
    File.basename($PROGRAM_NAME) == "rake"
  end

  # Returns the application.
  #
  # @param &block [Proc]
  #
  # @return [Ramverk::Application]
  def self.application(&block)
    @application.class_eval(&block) if block_given?
    @application
  end

  # @private
  def self.application=(app)
    raise "an application has already been registered" if @application

    @application = app
  end

  # @private
  def self.reset
    @application = nil
    Controller.configuration.reset
  end
end
