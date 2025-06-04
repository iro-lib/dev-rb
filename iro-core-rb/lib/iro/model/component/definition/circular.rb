# frozen_string_literal: true

module Iro
  module Model
    module Component
      module Definition
        class Circular < Base
          def initialize(**options)
            super

            return if boundary.bound?

            raise ArgumentError, "`:bounds` is invalid. Expected a Range[Numeric], got: #{options[:bounds].inspect}"
          end

          def contract(value, scalar)
            (value / scalar) % FRACTION_RANGE.end
          end

          def decrement(value, amount)
            (value - amount) % FRACTION_RANGE.end
          end

          def denormalize(value)
            normalized = value % FRACTION_RANGE.end
            (normalized * boundary.width) + boundary.min
          end

          def denormalize_to_percentage(value)
            value * PERCENTAGE_RANGE.end
          end

          def exponentiate(value, exponent)
            (value**exponent) % FRACTION_RANGE.end
          end

          def increment(value, amount)
            (value + amount) % FRACTION_RANGE.end
          end

          def normalize(value)
            normalized = ((value - boundary.min) / boundary.width) % FRACTION_RANGE.end
            normalized.negative? ? normalized + FRACTION_RANGE.end : normalized
          end

          def normalize_from_percentage(percentage)
            percentage / PERCENTAGE_RANGE.end
          end

          def root(value, amount)
            (value**(1.0 / amount)) % FRACTION_RANGE.end
          end

          def scale(value, scalar)
            (value * scalar) % FRACTION_RANGE.end
          end
        end
      end
    end
  end
end
