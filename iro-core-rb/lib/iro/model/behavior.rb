# frozen_string_literal: true

module Iro
  module Model
    module Behavior
      class << self
        private

        def included(base)
          super

          base.extend  ClassMethods
          base.extend  Support::Concurrent::InstanceVariable
          base.include InstanceMethods
        end
      end

      module ClassMethods
        attr_reader :model

        def ===(other)
          model === other
        end

        def components
          concurrent_instance_variable_fetch(:components, Component::Definition::Set.new)
        end

        protected

        def implements(model, &)
          concurrent_instance_variable_set(:model, model)
          model.implement(self, &)
        end

        private

        def inherited(subclass)
          super

          return unless model

          subclass.send(:implements, model)
        end
      end

      module InstanceMethods
        attr_reader :components

        def with_components(normalized: false, **component_mapping)
          component_mapping = component_mapping.each_with_object({}) do |(identifier_or_name, value), hash|
            definition = self.class.components[identifier_or_name]
            raise ArgumentError, "`#{identifier_or_name}` is not a valid component" unless definition

            hash[definition.identifier] = (normalized ? value : definition.normalize(value))
          end

          component_mapping = components.to_normalized_hash.merge(component_mapping)

          dup.tap do |duped|
            duped.instance_variable_set(
              :@components,
              Component::Set.new(duped, *component_mapping.values, normalized: true),
            )
            duped.send(:on_component_change, self)
          end
        end

        protected

        def on_component_change(source); end

        private

        def initialize_components!(*components, **options)
          @components = Component::Set.new(self, *components, normalized: options.fetch(:normalized, false))

          return unless options.fetch(:validate, true) && !@components.valid?

          raise InvalidComponentValueError, "#{self.class} values #{components.join(', ')} are invalid"
        end
      end
    end
  end
end
