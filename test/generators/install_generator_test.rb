# frozen_string_literal: true

require "test_helper"
require "rails/generators/test_case"
require "generators/action_passkey/install/install_generator"

class ActionPasskeyInstallGeneratorTest < Rails::Generators::TestCase # rubocop:disable Metrics/ClassLength
  tests ActionPasskey::Generators::InstallGenerator
  destination File.expand_path("../tmp/generators", __dir__)

  setup do
    prepare_destination
    FileUtils.mkdir_p File.join(destination_root, "config")
    File.write File.join(destination_root, "config/routes.rb"), "Rails.application.routes.draw do\nend\n"
    File.write File.join(destination_root, "config/importmap.rb"), <<~RUBY
      pin "application"
      pin_all_from "app/javascript/controllers", under: "controllers"
    RUBY
  end

  def test_install_generator_creates_initializer
    run_generator

    assert_file "config/initializers/action_passkey.rb" do |initializer|
      assert_match(/ActionPasskey.configure do \|config\|/, initializer)
      assert_match(%r{config.origins = \["http://localhost:3000"\]}, initializer)
      assert_match(/config.name = "My Application"/, initializer)
      refute_match(/after_authentication_path/, initializer)
      refute_match(/user_class_name/, initializer)
      refute_match(/verify_attestation_statement/, initializer)
      refute_match(/config.origin =/, initializer)
    end
  end

  def test_install_generator_creates_passkey_files
    run_generator

    assert_file "app/models/passkey.rb", /class Passkey < ApplicationRecord/
    assert_migration "db/migrate/create_passkeys.rb" do |migration|
      assert_match(/create_table :passkeys/, migration)
      assert_match(/t.references :user, null: false, foreign_key: true/, migration)
      assert_match(/t.string :external_id, null: false/, migration)
      assert_match(/add_index :passkeys, :external_id, unique: true/, migration)
    end
  end

  def test_install_generator_creates_explicit_routes
    run_generator

    assert_file "config/routes.rb" do |routes|
      assert_match(/resources :passkeys, only: :create/, routes)
      assert_match(/resource :passkey_session, only: :create/, routes)
      assert_match(/namespace :passkeys do\n    resource :options, only: :create\n  end/, routes)
      assert_match(/namespace :passkey_sessions do\n    resource :options, only: :create\n  end/, routes)
      refute_match(/to: "action_passkey/, routes)
      refute_match(/mount ActionPasskey::Engine/, routes)
    end
  end

  def test_install_generator_adds_has_passkeys_to_user_model
    FileUtils.mkdir_p File.join(destination_root, "app/models")
    File.write File.join(destination_root, "app/models/user.rb"), <<~RUBY
      class User < ApplicationRecord
      end
    RUBY

    run_generator

    assert_file "app/models/user.rb" do |user_model|
      assert_match(/class User < ApplicationRecord\n  has_passkeys\nend/, user_model)
    end
  end

  def test_install_generator_creates_passkey_javascript_files
    run_generator

    assert_file "app/javascript/controllers/passkey_registration_controller.js", /async register\(\)/
    assert_file "app/javascript/controllers/passkey_authentication_controller.js", /async authenticate\(\)/
    assert_file "app/javascript/helpers/passkey.js", /assertPasskeySupported/
    assert_file "app/javascript/helpers/post.js", /POST \$\{path\} failed/
    assert_file "app/javascript/helpers/headers.js", /X-CSRF-Token/
  end

  def test_install_generator_creates_host_app_passkey_controllers_and_helper
    run_generator

    assert_file "app/controllers/concerns/passkey_relying_party.rb", /module PasskeyRelyingParty/
    assert_file "app/controllers/passkeys_controller.rb", /class PasskeysController < ApplicationController/
    assert_file "app/controllers/passkeys/options_controller.rb",
                /class Passkeys::OptionsController < ApplicationController/
    assert_file "app/controllers/passkey_sessions_controller.rb",
                /class PasskeySessionsController < ApplicationController/
    assert_file "app/controllers/passkey_sessions/options_controller.rb",
                /class PasskeySessions::OptionsController < ApplicationController/
    assert_file "app/helpers/passkeys_helper.rb", /def add_passkey_button/
  end

  def test_install_generator_configures_importmap_for_passkey_javascript
    run_generator

    assert_file "config/importmap.rb" do |importmap|
      assert_match(%r{pin_all_from "app/javascript/helpers", under: "helpers"}, importmap)
      assert_match(%r{pin "@github/webauthn-json", to: "webauthn-json.js"}, importmap)
    end
    assert_file "vendor/javascript/webauthn-json.js", %r{@github/webauthn-json}
  end

  def test_install_generator_does_not_duplicate_routes
    run_generator
    run_generator

    assert_file "config/routes.rb" do |routes|
      assert_equal 1, routes.scan("resources :passkeys, only: :create").size
      assert_equal 1, routes.scan("resource :passkey_session, only: :create").size
      assert_equal 1, routes.scan("namespace :passkeys do").size
      assert_equal 1, routes.scan("namespace :passkey_sessions do").size
    end
  end

  def test_install_generator_does_not_duplicate_importmap_pins
    run_generator
    run_generator

    assert_file "config/importmap.rb" do |importmap|
      assert_equal 1, importmap.scan(%r{pin_all_from "app/javascript/helpers", under: "helpers"}).size
      assert_equal 1, importmap.scan(%r{pin "@github/webauthn-json", to: "webauthn-json.js"}).size
    end
  end

  def test_gem_does_not_ship_obsolete_namespaced_host_app_files
    assert_empty Dir.glob(File.expand_path("../../app/controllers/action_passkey/**/*.rb", __dir__))
    assert_empty Dir.glob(File.expand_path("../../app/controllers/concerns/action_passkey/**/*.rb", __dir__))
    assert_empty Dir.glob(File.expand_path("../../app/helpers/action_passkey/**/*.rb", __dir__))
  end
end
