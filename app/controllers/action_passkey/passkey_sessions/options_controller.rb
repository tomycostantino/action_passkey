# frozen_string_literal: true

module ActionPasskey
  module PasskeySessions
    class OptionsController < ApplicationController
      include PasskeyRelyingParty

      allow_unauthenticated_access

      def create
        options = passkey_relying_party.options_for_authentication(
          allow: Passkey.pluck(:external_id)
        )

        session[:passkey_authentication_challenge] = options.challenge

        render json: options
      end
    end
  end
end
