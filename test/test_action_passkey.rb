# frozen_string_literal: true

require "test_helper"

class TestActionPasskey < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ActionPasskey::VERSION
  end

  def test_configuration_only_exposes_origins_and_name
    configuration = ActionPasskey::Configuration.new

    assert_respond_to configuration, :origins
    assert_respond_to configuration, :origins=
    assert_respond_to configuration, :name
    assert_respond_to configuration, :name=
    refute_respond_to configuration, :origin
    refute_respond_to configuration, :after_authentication_path
    refute_respond_to configuration, :user_class_name
  end
end
