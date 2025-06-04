# frozen_string_literal: true

module Iro
  module Space
    module Behavior
      module Identification
        class << self
          private

          def included(base)
            super

            base.extend  Support::Concurrent::InstanceVariable
            base.extend  ClassMethods
            base.include InstanceMethods
          end
        end

        module ClassMethods
          def identifier
            concurrent_instance_variable_fetch(:identifier) do
              Support::Inflection.snake_case(name.split('::').last).to_sym
            end
          end

          protected

          def identified_as(identifier)
            concurrent_instance_variable_set(:identifier, identifier)
          end
        end

        module InstanceMethods
          def identifier
            concurrent_instance_variable_fetch(:identifier, self.class.identifier)
          end
        end
      end
    end
  end
end
