import { Controller } from "@hotwired/stimulus"
import { create } from "@github/webauthn-json"
import { assertPasskeySupported } from "helpers/passkey"
import post from "helpers/post"

export default class extends Controller {
  async register() {
    try {
      assertPasskeySupported()

      const passkeyOptions = await this.#createPasskeyOptions()
      const credential = await create({ publicKey: passkeyOptions })

      await this.#createPasskey(credential)

      window.alert("Passkey added")
    } catch (error) {
      window.alert(`Could not add passkey: ${error.message}`)
    }
  }

  async #createPasskeyOptions() {
    const response = await post("/passkeys/options")
    return response.json()
  }

  async #createPasskey(credential) {
    await post("/passkeys", { credential })
  }
}
