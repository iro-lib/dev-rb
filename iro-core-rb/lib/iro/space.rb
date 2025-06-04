# frozen_string_literal: true

module Iro
  module Space
    extend Support::Concurrent::InstanceVariable

    class << self
      def registry
        concurrent_instance_variable_fetch(:registry, Registry.new)
      end

      def transform
        concurrent_instance_variable_fetch(:transform, Transform::Registry.new)
      end
    end
  end
end
