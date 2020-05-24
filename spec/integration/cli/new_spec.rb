# frozen_string_literal: true

RSpec.describe "ramverk new APP_NAME", type: :cli do
  before { allow($stdout).to receive(:write) }

  it "creates a new app" do
    pwd = File.expand_path("spec/tmp", Dir.pwd)

    Dir.chdir pwd do
      ramverk "new", "test_app"

      root = Pathname.new(pwd).join("test_app")

      expect(root.join("README.md"))
        .to be_a_file
      expect(root.join(".gitignore"))
        .to be_a_file
      expect(root.join("Gemfile"))
        .to be_a_file
      expect(root.join("Rakefile"))
        .to be_a_file
      expect(root.join("config.ru"))
        .to be_a_file
      expect(root.join(".env.example"))
        .to be_a_file
      expect(root.join(".env.test"))
        .to be_a_file
      expect(root.join(".env.development"))
        .to be_a_file

      expect(root.join("lib", "test_app.rb"))
        .to be_a_file
      expect(root.join("lib", "test_app.rb"))
        .to include_text("module TestApp")
      expect(root.join("lib", "test_app", ".gitkeep"))
        .to be_a_file
      expect(root.join("lib", "models", ".gitkeep"))
        .to be_a_file

      expect(root.join("config", "application.rb"))
        .to be_a_file
      expect(root.join("config", "routes.rb"))
        .to be_a_file
      expect(root.join("config", "boot.rb"))
        .to be_a_file

      expect(root.join("spec", "spec_helper.rb"))
        .to be_a_file
      expect(root.join("spec", "lib", "test_app_spec.rb"))
        .to include_text("RSpec.describe TestApp do")
      expect(root.join("spec", "app", "controllers", "pages_spec.rb"))
        .to be_a_file

      expect(root.join("app", "controllers", "application.rb"))
        .to be_a_file
      expect(root.join("app", "controllers", "pages.rb"))
        .to be_a_file

      expect(root.join("public/robots.txt"))
        .to be_a_file
    end
  end
end
