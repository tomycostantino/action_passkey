# frozen_string_literal: true

module ActionPasskey
  module Passkeys
    class OptionsController < ApplicationController
      include PasskeyRelyingParty

      def create
        options = passkey_relying_party.options_for_registration(
          user: registration_user_options,
          exclude: Current.user.passkeys.pluck(:external_id)
        )

        session[:passkey_registration_challenge] = options.challenge

        render json: options
      end

      private

      def registration_user_options
        {
          id: WebAuthn.standard_encoder.encode(Current.user.id.to_s),
          name: Current.user.email_address,
          display_name: Current.user.email_address
        }
      end
    end
  end
end
