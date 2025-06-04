# frozen_string_literal: true

module Iro
  class << self
    def plug(...)
      Runtime.plugin.register(...)
    end
  end
end
