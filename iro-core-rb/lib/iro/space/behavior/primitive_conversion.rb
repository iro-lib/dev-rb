# frozen_string_literal: true

module Iro
  module Space
    module Behavior
      module PrimitiveConversion
        class << self
          private

          def included(base)
            super

            base.include InstanceMethods
          end
        end

        module InstanceMethods
          def to_array
            components.to_normalized
          end
          alias to_a to_array

          def to_string
            if respond_to?(:opacity) && opacity < PERCENTAGE_RANGE.end
              "#{self.class}(:#{identifier}a, #{components.to_string}, #{opacity.round(2)}%)"
            else
              "#{self.class}(:#{identifier}, #{components.to_string})"
            end
          end
          alias to_s to_string
        end
      end
    end
  end
end
