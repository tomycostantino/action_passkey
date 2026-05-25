# frozen_string_literal: true

require "test_helper"
require "active_record"

class HasPasskeysTest < Minitest::Test
  class User < ActiveRecord::Base
    self.table_name = "users"

    has_passkeys
  end

  def test_has_passkeys_adds_passkeys_association
    association = User.reflect_on_association(:passkeys)

    assert_equal :has_many, association.macro
    assert_equal "Passkey", association.class_name
    assert_equal :destroy, association.options[:dependent]
  end
end
