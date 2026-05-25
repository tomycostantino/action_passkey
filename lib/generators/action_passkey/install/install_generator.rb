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

      def mount_engine
        route 'mount ActionPasskey::Engine => "/"'
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
