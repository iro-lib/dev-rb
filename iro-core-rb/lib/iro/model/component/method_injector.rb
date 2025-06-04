# frozen_string_literal: true

module Iro
  module Model
    module Component
      module MethodInjector
        class << self
          def call(base, definition)
            identifier = definition.identifier
            name       = definition.name

            # Define the basic getter methods
            base.define_method(identifier) { components.public_send(identifier) }
            base.define_method(name) { components.public_send(name) } unless identifier == name

            base.define_method(:"#{name}_percentage") do
              definition.denormalize_to_percentage(components.public_send(identifier))
            end

            # Define with_<name>_contracted_by methods
            define_derivative_method(:contract, base, definition) do |value, amount|
              if value.zero? && amount > 1 && definition.boundary.bound?
                value =
                  [definition.normalize(definition.boundary.maximum * 0.01), definition.differential_step].min
              end

              definition.clamp(definition.contract(value, amount))
            end

            # Define with_<name>_decremented_by methods
            define_derivative_method(:decrement, base, definition, default_value: true) do |value, amount|
              definition.clamp(definition.decrement(value, definition.normalize(amount)))
            end

            # Define with_<name>_incremented_by methods
            define_derivative_method(:increment, base, definition, default_value: true) do |value, amount|
              definition.clamp(definition.increment(value, definition.normalize(amount)))
            end

            # Define with_<name>_scaled_by methods
            define_derivative_method(:scale, base, definition, default_value: true) do |value, amount|
              if value.zero? && amount > 1 && definition.boundary.bound?
                value = [definition.normalize(definition.boundary.maximum * 0.01), definition.differential_step].min
              end

              definition.clamp(definition.scale(value, amount))
            end
          end

          private

          def define_derivative_method(method_name, base, definition, default_value: false)
            component_name     = definition.name
            tensed_method_name = method_name.end_with?('e') ? :"#{method_name}d" : "#{method_name}ed"
            with_method_name   = :"with_#{component_name}_#{tensed_method_name}_by"
            aliased_name       = :"#{method_name}_#{component_name}"

            if default_value
              base.define_method(with_method_name) do |amount = definition.differential_step|
                new_value = yield(components.public_send(definition.identifier), amount)
                with_components(definition.identifier => new_value)
              end
            else
              base.define_method(with_method_name) do |amount|
                new_value = yield(components.public_send(definition.identifier), amount)
                with_components(definition.identifier => new_value)
              end
            end

            base.alias_method(aliased_name, with_method_name)
          end
        end
      end
    end
  end
end
