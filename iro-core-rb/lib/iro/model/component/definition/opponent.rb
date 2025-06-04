# frozen_string_literal: true

module Iro
  module Model
    module Component
      module Definition
        class Opponent < Linear
          def contract(value, scalar)
            if boundary.unbound?
              value / scalar
            else
              (value - boundary.center) / (scalar + boundary.center)
            end
          end

          def exponentiate(value, exponent)
            if boundary.unbound?
              value**exponent
            else
              ((value - boundary.center)**exponent) + boundary.center
            end
          end

          def root(value, amount)
            if boundary.unbound?
              value**(1.0 / amount)
            else
              ((value - boundary.center)**(1.0 / amount)) + boundary.center
            end
          end

          def scale(value, scalar)
            if boundary.unbound?
              value * scalar
            else
              (value - boundary.center) * scalar
            end
          end
        end
      end
    end
  end
end
