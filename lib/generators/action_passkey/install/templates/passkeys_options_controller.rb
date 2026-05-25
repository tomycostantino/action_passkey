class Passkeys::OptionsController < ApplicationController
  include PasskeyRelyingParty

  def create
    options = passkey_relying_party.options_for_registration(
      user: {
        id: WebAuthn.standard_encoder.encode(Current.user.id.to_s),
        name: Current.user.email_address,
        display_name: Current.user.email_address
      },
      exclude: Current.user.passkeys.pluck(:external_id)
    )

    session[:passkey_registration_challenge] = options.challenge

    render json: options
  end
end
