class PasskeySessionsController < ApplicationController
  include PasskeyRelyingParty

  allow_unauthenticated_access

  def create
    credential, passkey = passkey_relying_party.verify_authentication(
      passkey_params.to_h,
      session.delete(:passkey_authentication_challenge)
    ) do |webauthn_credential|
      Passkey.find_by!(external_id: webauthn_credential.id)
    end

    passkey.update!(sign_count: credential.sign_count)
    start_new_session_for passkey.user

    render json: { location: after_authentication_url }, status: :created
  end

  private
    def passkey_params
      params.require(:credential).permit(
        :id, :rawId, :type,
        response: [ :clientDataJSON, :authenticatorData, :signature, :userHandle ]
      )
    end
end
