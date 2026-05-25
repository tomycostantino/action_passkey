export function assertPasskeySupported() {
  if (!window.PublicKeyCredential) {
    throw new Error("This browser does not support passkeys.")
  }
}
