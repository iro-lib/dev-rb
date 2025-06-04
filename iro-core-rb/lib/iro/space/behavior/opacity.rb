# frozen_string_literal: true

module Iro
  module Space
    module Behavior
      module Opacity
        class << self
          private

          def included(base)
            super

            base.include InstanceMethods
          end
        end

        module InstanceMethods
          attr_reader :opacity
          alias alpha opacity

          def with_opacity(opacity)
            unless opacity.is_a?(Numeric) && PERCENTAGE_RANGE.cover?(opacity)
              raise TypeError, "`opacity` is invalid. Expected `Numeric` between 0.0 and 100.0, got: #{opacity}"
            end

            dup.tap { |duped| duped.instance_variable_set(:@opacity, opacity) }
          end
          alias with_alpha with_opacity

          def with_opacity_contracted_by(amount)
            with_opacity((opacity / amount.to_f).clamp(PERCENTAGE_RANGE))
          end
          alias contract_alpha           with_opacity_contracted_by
          alias contract_opacity         with_opacity_contracted_by
          alias with_alpha_contracted_by with_opacity_contracted_by

          def with_opacity_decremented_by(amount)
            with_opacity((opacity - amount.to_f).clamp(PERCENTAGE_RANGE))
          end
          alias decrement_alpha           with_opacity_decremented_by
          alias decrement_opacity         with_opacity_decremented_by
          alias with_alpha_decremented_by with_opacity_decremented_by

          def with_opacity_incremented_by(amount)
            with_opacity((opacity + amount.to_f).clamp(PERCENTAGE_RANGE))
          end
          alias increment_alpha           with_opacity_incremented_by
          alias increment_opacity         with_opacity_incremented_by
          alias with_alpha_incremented_by with_opacity_incremented_by

          def with_opacity_scaled_by(amount)
            with_opacity((opacity * amount.to_f).clamp(PERCENTAGE_RANGE))
          end
          alias scale_alpha          with_opacity_scaled_by
          alias scale_opacity        with_opacity_scaled_by
          alias with_alpha_scaled_by with_opacity_scaled_by

          private

          def initialize_opacity!(**options)
            opacity = options.fetch(:opacity, options.fetch(:alpha, PERCENTAGE_RANGE.end)).to_f

            unless opacity.is_a?(Numeric)
              raise TypeError, "`:opacity` is invalid. Expected `Numeric`, got: #{opacity.class}"
            end

            unless PERCENTAGE_RANGE.cover?(opacity)
              raise ArgumentError, "`:opacity` is invalid. Expected `Numeric` between 0.0 and 100.0, got: #{opacity}"
            end

            @opacity = opacity
          end
        end
      end
    end
  end
end
