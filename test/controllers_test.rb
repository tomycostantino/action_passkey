# frozen_string_literal: true

require "test_helper"
require "action_controller/railtie"

unless defined?(ApplicationController)
  class ApplicationController < ActionController::Base
    def self.allow_unauthenticated_access; end
  end
end

load File.expand_path("../lib/generators/action_passkey/install/templates/passkey_relying_party.rb", __dir__)
load File.expand_path("../lib/generators/action_passkey/install/templates/passkeys_controller.rb", __dir__)
module Passkeys; end
load File.expand_path("../lib/generators/action_passkey/install/templates/passkeys_options_controller.rb", __dir__)
load File.expand_path("../lib/generators/action_passkey/install/templates/passkey_sessions_controller.rb", __dir__)
module PasskeySessions; end
load File.expand_path(
  "../lib/generators/action_passkey/install/templates/passkey_sessions_options_controller.rb",
  __dir__
)

class ControllersTest < Minitest::Test
  def test_passkey_controllers_inherit_from_application_controller
    assert_operator PasskeysController, :<, ApplicationController
    assert_operator Passkeys::OptionsController, :<, ApplicationController
    assert_operator PasskeySessionsController, :<, ApplicationController
    assert_operator PasskeySessions::OptionsController, :<, ApplicationController
  end

  def test_passkey_relying_party_template_loads_its_dependencies
    assert defined?(WebAuthn::RelyingParty), "expected WebAuthn::RelyingParty to be loaded"
    assert URI.respond_to?(:parse)
  end
end
