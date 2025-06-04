# frozen_string_literal: true

module Iro
  module Space
    module Behavior
      module Comparison
        class << self
          private

          def included(base)
            super

            base.include InstanceMethods
          end
        end

        module InstanceMethods
          def ==(other)
            components == coerce(other).components
          rescue CoercionError
            false
          end

          def is_a?(mod)
            mod == Space || super
          end
        end
      end
    end
  end
end
