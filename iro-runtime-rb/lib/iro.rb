# frozen_string_literal: true

module Iro
  class << self
    def plug(...)
      Runtime.plugin.register(...)
      Support::Callback.resolve
    end
  end
end
