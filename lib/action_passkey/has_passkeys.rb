# frozen_string_literal: true

require "active_support/concern"

module ActionPasskey
  module HasPasskeys
    extend ActiveSupport::Concern

    class_methods do
      def has_passkeys
        has_many :passkeys, dependent: :destroy
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include ActionPasskey::HasPasskeys
end
