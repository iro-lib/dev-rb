# frozen_string_literal: true

module Iro
  module Runtime
    class Plugin
      class DSL
        class ModuleEnhancer < BasicObject
          def initialize(mod, &block)
            @mod    = mod
            @target = mod

            block&.arity&.zero? ? instance_exec(&block) : (yield(self) if block)
          end

          def class_methods
            @target = @mod.singleton_class
            yield(self)
          ensure
            @target = @mod
          end

          def intercept_method(method_name, &override_block)
            original_method = @target.instance_method(method_name)

            @target.override_method(method_name) do |*arguments, **keyword_arguments, &original_block|
              result = original_method.bind_call(self, *arguments, **keyword_arguments, &original_block)
              @target.instance_exec(result, *arguments, **keyword_arguments, &override_block)
            end
          end

          def override_constant(constant_name, override_value = Support::Type::Undefined, &block)
            constant = @mod.const_get(constant_name) if @mod.const_defined?(constant_name)
            @mod.send(:remove_const, constant_name) if @mod.const_defined?(constant_name)

            constant_value = if Support::Type::Undefined === override_value
                               block&.arity&.zero? ? instance_exec(&block) : (yield(constant) if block)
                             else
                               override_value
                             end

            @mod.const_set(constant_name, constant_value)
          end

          def override_method(method_name, &)
            @target.undef_method(method_name) if @target.method_defined?(method_name)
            @target.define_method(method_name, &)
          end

          def prefix_method(method_name)
            original_method = @target.instance_method(method_name)

            @target.override_method(method_name) do |*arguments, **keyword_arguments, &original_block|
              new_arguments = @target.instance_exec(*arguments, **keyword_arguments, &original_block)
              original_method.bind_call(self, *new_arguments)
            end
          end

          private

          def method_missing(method, ...)
            return super unless respond_to_missing?(method, true)

            @target.__send__(method, ...)
          end

          def respond_to_missing?(method, include_private = false)
            @target.respond_to?(method, include_private) || super
          end
        end
      end
    end
  end
end
