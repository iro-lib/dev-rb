# frozen_string_literal: true

module Iro
  module Space
    module Behavior
      module Coercion
        class << self
          private

          def included(base)
            super

            base.extend  ClassMethods
            base.include Core::Coercion

            base.instance_eval do
              coerce_from Array, if: ->(array) { components.valid?(*array) } do |other|
                new(*other)
              end

              coerce_from if: ->(other) { other.respond_to?(:"to_#{identifier}") } do |other|
                other.public_send(:"to_#{identifier}")
              end
            end
          end
        end

        module ClassMethods
          def from_fraction(*, **)
            new(*, normalized: true, **)
          end

          def from_intermediate(*, **)
            from_fraction(*, validate: false, **)
          end

          def from_percentage(*components, **)
            components = self.components.map.with_index do |definition, index|
              value = components[index]
              next unless value

              definition.normalize_from_percentage(value)
            end

            from_fraction(*components, **)
          end
        end
      end
    end
  end
end
