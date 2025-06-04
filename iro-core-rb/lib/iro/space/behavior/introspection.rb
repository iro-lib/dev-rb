# frozen_string_literal: true

module Iro
  module Space
    module Behavior
      module Introspection
        class << self
          private

          def included(base)
            super

            base.include InstanceMethods
          end
        end

        module InstanceMethods
          def inspect
            to_string
          end

          private

          def cache_attributes
            [identifier, *components.to_denormalized]
          end
        end
      end
    end
  end
end
