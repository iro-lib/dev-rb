# frozen_string_literal: true

module Iro
  module Space
    module Behavior
      module Abstract
        class << self
          private

          def included(base)
            super

            base.extend Support::Concurrent::InstanceVariable
            base.extend ClassMethods
          end
        end

        module ClassMethods
          def abstract_space?
            concurrent_instance_variable_fetch(:abstract_space, false)
          end

          protected

          def abstract_space
            concurrent_instance_variable_set(:abstract_space, true)
          end
        end
      end
    end
  end
end
