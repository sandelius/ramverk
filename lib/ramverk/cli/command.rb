# frozen_string_literal: true

require "thor"
require "shellwords"

require "ramverk/version"
require "ramverk/naming"

module Ramverk
  module Cli
    # Main command class for the Ramverk framework.
    #
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    class Command < Thor
      include Thor::Actions

      desc "version", "Print framework version"
      def version
        puts Ramverk::VERSION
      end

      desc "new APP_NAME", "Generate a new app"
      def new(app_name)
        app_name = Shellwords.escape(app_name)
        app_name = Ramverk::Naming.underscore(app_name)
        app_namespace = Ramverk::Naming.classify(app_name)

        config = {
          app_name: app_name,
          app_namespace: app_namespace
        }

        root = Pathname.new(Dir.pwd).join(app_name)

        template "new/README.md.tt", root.join("README.md"), config
        template "new/.gitignore.tt", root.join(".gitignore"), config
        template "new/Gemfile.tt", root.join("Gemfile"), config
        template "new/Rakefile.tt", root.join("Rakefile"), config
        template "new/config.ru.tt", root.join("config.ru"), config
        template "new/.env.example.tt", root.join(".env.example"), config
        template "new/.env.test.tt", root.join(".env.test"), config
        template "new/.env.development.tt", root.join(".env.development"), config

        template "new/lib/app.rb.tt", root.join("lib", "#{app_name}.rb"), config
        create_file root.join("lib", app_name, ".gitkeep")
        create_file root.join("lib", "models", ".gitkeep")

        template "new/config/application.rb.tt", root.join("config", "application.rb"), config
        template "new/config/routes.rb.tt", root.join("config", "routes.rb"), config
        template "new/config/boot.rb.tt", root.join("config", "boot.rb"), config

        template "new/spec/spec_helper.rb.tt", root.join("spec", "spec_helper.rb"), config
        template "new/spec/app/app_spec.rb.tt", root.join("spec", app_name, "#{app_name}_spec.rb"), config
        create_file root.join("spec", "support", ".gitkeep")

        template "new/public/robots.txt.tt", root.join("public", "robots.txt"), config
      end

      # Source path for templates used by generators.
      #
      # This need to be defined in third-part commands in order for the tool
      # to find template sources.
      #
      # @return [String]
      def self.source_root
        File.expand_path("templates", __dir__)
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
end
