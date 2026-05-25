# frozen_string_literal: true

require "test_helper"
require "action_view"

load File.expand_path("../../lib/generators/action_passkey/install/templates/passkeys_helper.rb", __dir__)

class PasskeysHelperTest < Minitest::Test
  include ActionView::Helpers::TagHelper
  include ActionView::Context
  include PasskeysHelper

  def test_add_passkey_button_renders_registration_controller_button
    html = add_passkey_button

    assert_includes html, "data-controller=\"passkey-registration\""
    assert_includes html, "data-action=\"passkey-registration#register\""
    assert_includes html, "Add passkey"
  end

  def test_sign_in_with_passkey_button_renders_authentication_controller_button
    html = sign_in_with_passkey_button

    assert_includes html, "data-controller=\"passkey-authentication\""
    assert_includes html, "data-action=\"passkey-authentication#authenticate\""
    assert_includes html, "Sign in with passkey"
  end
end
