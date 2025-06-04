# frozen_string_literal: true

module Iro
  module Runtime
    extend Support::Concurrent::InstanceVariable

    class << self
      def constant
        ConstantInterface
      end

      def plugin
        concurrent_instance_variable_fetch(:plugin, Plugin::Registry.new)
      end
    end
  end
end
