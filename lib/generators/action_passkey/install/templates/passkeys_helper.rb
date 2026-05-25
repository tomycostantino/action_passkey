module PasskeysHelper
  def add_passkey_button
    content_tag(:div, data: { controller: "passkey-registration" }) do
      tag.button("Add passkey", type: "button", data: { action: "passkey-registration#register" })
    end
  end

  def sign_in_with_passkey_button
    content_tag(:div, data: { controller: "passkey-authentication" }) do
      tag.button("Sign in with passkey", type: "button", data: { action: "passkey-authentication#authenticate" })
    end
  end
end
