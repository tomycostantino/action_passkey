# frozen_string_literal: true

require "test_helper"
require "rails/generators/test_case"
require "generators/action_passkey/install/install_generator"

class ActionPasskeyInstallGeneratorTest < Rails::Generators::TestCase
  tests ActionPasskey::Generators::InstallGenerator
  destination File.expand_path("../tmp/generators", __dir__)

  setup do
    prepare_destination
    FileUtils.mkdir_p File.join(destination_root, "config")
    File.write File.join(destination_root, "config/routes.rb"), "Rails.application.routes.draw do\nend\n"
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
    assert_file "config/routes.rb", %r{mount ActionPasskey::Engine => "/"}
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
end
