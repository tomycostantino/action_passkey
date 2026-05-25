# frozen_string_literal: true

module ActionPasskey
  class PasskeysController < ApplicationController
    include PasskeyRelyingParty

    def create
      credential = passkey_relying_party.verify_registration(
        passkey_params.to_h,
        session.delete(:passkey_registration_challenge)
      )

      Current.user.passkeys.create!(
        external_id: credential.id,
        public_key: credential.public_key,
        sign_count: credential.sign_count
      )

      render json: { status: "created" }, status: :created
    end

    private

    def passkey_params
      params.require(:credential).permit(
        :id, :rawId, :type,
        response: %i[clientDataJSON attestationObject]
      )
    end
  end
end
