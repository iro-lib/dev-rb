# frozen_string_literal: true

module Iro
  module Model
    extend Support::Concurrent::InstanceVariable

    class << self
      def ===(other)
        (other.respond_to?(:components) && other.components.is_a?(Component::Set)) || super
      end

      def registry
        concurrent_instance_variable_fetch(:registry, Registry.new)
      end
    end
  end
end
