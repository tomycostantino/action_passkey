module PasskeyRelyingParty
  extend ActiveSupport::Concern

  private

    def passkey_relying_party
      @passkey_relying_party ||= WebAuthn::RelyingParty.new(
        allowed_origins: ActionPasskey.configuration.origins,
        id: URI(ActionPasskey.configuration.origins.first).host,
        name: ActionPasskey.configuration.name,
        verify_attestation_statement: false
      )
    end
end
