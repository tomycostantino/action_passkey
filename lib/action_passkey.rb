# frozen_string_literal: true

require_relative "action_passkey/version"
require_relative "action_passkey/engine"

module ActionPasskey
  class Error < StandardError; end

  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield configuration
    end
  end

  class Configuration
    attr_accessor :origins, :name

    def initialize
      @origins = []
      @name = "My Application"
    end
  end
end
