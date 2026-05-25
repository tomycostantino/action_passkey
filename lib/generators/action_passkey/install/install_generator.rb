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
