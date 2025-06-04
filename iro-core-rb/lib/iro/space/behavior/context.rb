# frozen_string_literal: true

module Iro
  module Space
    module Behavior
      module Context
        class << self
          private

          def included(base)
            super

            base.extend  Support::Concurrent::InstanceVariable
            base.extend  ClassMethods
            base.include InstanceMethods
          end
        end

        module ClassMethods
          attr_reader :context

          protected

          def contextualize(&)
            context_class = Class.new(Space::Context, &)
            const_set(:Context, context_class)
          end

          def use_context(context_class)
            unless context_class.is_a?(Class) && context_class < Space::Context
              raise TypeError, '`context_class` is invalid. Expected subclass of `Iro::Space::Context`, ' /
                               "got: #{context_class}"
            end

            const_set(:Context, context_class)
          end

          def with_native(**attributes)
            concurrent_instance_variable_set(:context, self::Context.new(**attributes))
          end
        end

        module InstanceMethods
          attr_reader :context

          def with_context(**attributes)
            new_context = context&.with(**attributes) || self.class.context&.with(**attributes)
            new_context ||= self.class::Context.new(**attributes) if self.class.const_defined?(:Context)
            return self unless new_context
            return self if context == new_context

            new_context.adapt(self)
          end

          private

          def initialize_context!(**attributes)
            if self.class.context
              @context = self.class.context.with(**attributes)
            elsif self.class.const_defined?(:Context)
              @context = self.class::Context.new(**attributes)
            end
          end
        end
      end
    end
  end
end
