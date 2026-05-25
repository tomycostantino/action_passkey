# frozen_string_literal: true

require "test_helper"
require "action_controller/railtie"

unless defined?(ApplicationController)
  class ApplicationController < ActionController::Base
    def self.allow_unauthenticated_access; end
  end
end

require_relative "../app/controllers/concerns/action_passkey/passkey_relying_party"
require_relative "../app/controllers/action_passkey/passkeys_controller"
require_relative "../app/controllers/action_passkey/passkeys/options_controller"
require_relative "../app/controllers/action_passkey/passkey_sessions_controller"
require_relative "../app/controllers/action_passkey/passkey_sessions/options_controller"

class ControllersTest < Minitest::Test
  def test_passkey_controllers_inherit_from_application_controller
    assert_operator ActionPasskey::PasskeysController, :<, ApplicationController
    assert_operator ActionPasskey::Passkeys::OptionsController, :<, ApplicationController
    assert_operator ActionPasskey::PasskeySessionsController, :<, ApplicationController
    assert_operator ActionPasskey::PasskeySessions::OptionsController, :<, ApplicationController
  end
end
