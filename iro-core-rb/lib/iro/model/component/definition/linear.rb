# frozen_string_literal: true

module Iro
  module Model
    module Component
      module Definition
        class Linear < Base
          def contract(value, scalar)
            value / scalar
          end

          def decrement(value, amount)
            value - amount
          end

          def denormalize(value)
            return value if boundary.unbound?

            (value * boundary.width) + boundary.min
          end

          def denormalize_to_percentage(value)
            if boundary.unbound?
              ((value + 1.0) / 2.0) * PERCENTAGE_RANGE.end
            else
              value * PERCENTAGE_RANGE.end
            end
          end

          def exponentiate(value, exponent)
            value**exponent
          end

          def increment(value, amount)
            value + amount
          end

          def normalize(value)
            return value if boundary.unbound?

            (value - boundary.min) / boundary.width
          end

          def normalize_from_percentage(percentage)
            fraction = percentage / PERCENTAGE_RANGE.end
            boundary.unbound? ? (fraction * 2.0) - 1.0 : fraction
          end

          def root(value, amount)
            value**(1.0 / amount)
          end

          def scale(value, scalar)
            value * scalar
          end
        end
      end
    end
  end
end
