import { Controller } from "@hotwired/stimulus"
import { get } from "@github/webauthn-json"
import { assertPasskeySupported } from "helpers/passkey"
import post from "helpers/post"

export default class extends Controller {
  async authenticate() {
    try {
      assertPasskeySupported()

      const passkeyOptions = await this.#createPasskeyOptions()
      const credential = await get({ publicKey: passkeyOptions })
      const result = await this.#createSession(credential)

      window.location.href = result.location
    } catch (error) {
      window.alert(`Could not sign in with passkey: ${error.message}`)
    }
  }

  async #createPasskeyOptions() {
    const response = await post("/passkey_sessions/options")
    return response.json()
  }

  async #createSession(credential) {
    const response = await post("/passkey_session", { credential })
    return response.json()
  }
}
