# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

module ActionPasskey
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      def copy_initializer
        template "action_passkey.rb", "config/initializers/action_passkey.rb"
      end

      def copy_passkey_model
        template "passkey.rb", "app/models/passkey.rb"
      end

      def copy_controller_files
        copy_file "passkey_relying_party.rb", "app/controllers/concerns/passkey_relying_party.rb"
        copy_file "passkeys_controller.rb", "app/controllers/passkeys_controller.rb"
        copy_file "passkeys_options_controller.rb", "app/controllers/passkeys/options_controller.rb"
        copy_file "passkey_sessions_controller.rb", "app/controllers/passkey_sessions_controller.rb"
        copy_file "passkey_sessions_options_controller.rb", "app/controllers/passkey_sessions/options_controller.rb"
      end

      def copy_helper_file
        copy_file "passkeys_helper.rb", "app/helpers/passkeys_helper.rb"
      end

      def copy_javascript_files
        copy_file "passkey_registration_controller.js", "app/javascript/controllers/passkey_registration_controller.js"
        copy_file "passkey_authentication_controller.js",
                  "app/javascript/controllers/passkey_authentication_controller.js"
        copy_file "passkey.js", "app/javascript/helpers/passkey.js"
        copy_file "post.js", "app/javascript/helpers/post.js"
        copy_file "headers.js", "app/javascript/helpers/headers.js"
        copy_file "webauthn-json.js", "vendor/javascript/webauthn-json.js"
      end

      def configure_importmap
        return unless File.exist?(File.join(destination_root, "config/importmap.rb"))

        append_to_file "config/importmap.rb", <<~RUBY

          pin_all_from "app/javascript/helpers", under: "helpers"
          pin "@github/webauthn-json", to: "webauthn-json.js"
        RUBY
      end

      def copy_passkey_migration
        migration_template "create_passkeys.rb", "db/migrate/create_passkeys.rb"
      end

      def add_has_passkeys_to_user_model
        return unless File.exist?(File.join(destination_root, "app/models/user.rb"))

        inject_into_class "app/models/user.rb", "User", "  has_passkeys\n"
      end

      def add_routes
        route <<~RUBY
          resources :passkeys, only: :create
          resource :passkey_session, only: :create

          namespace :passkeys do
            resource :options, only: :create
          end

          namespace :passkey_sessions do
            resource :options, only: :create
          end
        RUBY
      end

      def migration_version
        "[#{ActiveRecord::Migration.current_version}]"
      end

      def self.next_migration_number(dirname)
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end
    end
  end
end
