# frozen_string_literal: true

module Iro
  class Chromaticity
    extend  Support::Concurrent::InstanceVariable
    include Model::Behavior
    include Space::Behavior::Abstract
    include Space::Behavior::Coercion
    include Space::Behavior::Context
    include Space::Behavior::Identification
    include Space::Behavior::Introspection
    include Space::Behavior::Transform
    include Support::Concurrent::InstanceVariable

    abstract_space

    def initialize(*, **)
      raise AbstractSpaceError, "#{self.class} is abstract and cannot be instantiated" if self.class.abstract_space?

      @mutex = Mutex.new
      initialize_components!(*, **)
    end

    def ==(other)
      components == coerce(other).components
    rescue CoercionError
      false
    end

    def to_array
      components.to_normalized
    end
    alias to_a to_array

    def to_string
      "#{self.class}(:#{identifier}, #{components.to_string})"
    end
    alias to_s to_string
  end
end
