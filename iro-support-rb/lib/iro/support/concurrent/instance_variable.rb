# frozen_string_literal: true

module Iro
  module Support
    module Concurrent
      module InstanceVariable
        class << self
          private

          def extended(base)
            super

            base.instance_variable_set(:@mutex, Mutex.new) unless base.instance_variable_defined?(:@mutex)
            base.extend ClassMethods
            base.extend Methods
          end

          def included(base)
            base.include Methods
          end
        end

        module ClassMethods
          private

          def inherited(subclass)
            super

            subclass.instance_variable_set(:@mutex, Mutex.new)
          end
        end

        module Methods
          def concurrent_instance_variable_fetch(name, value = nil, &block)
            unless instance_variable_defined?(:@mutex)
              raise Error, "#{self.class} must define `@mutex = Mutex.new` in initialize method when including " \
                           "#{InstanceVariable}"
            end

            ivar = name.to_s.delete_prefix('@')

            return instance_variable_get(:"@#{ivar}") if instance_variable_defined?(:"@#{ivar}")

            @mutex.synchronize do
              unless instance_variable_defined?(:"@#{ivar}")
                computed_value = block ? yield : value
                instance_variable_set(:"@#{ivar}", computed_value)
              end
            end

            instance_variable_get(:"@#{ivar}")
          end

          def concurrent_instance_variable_set(name, value)
            unless instance_variable_defined?(:@mutex)
              raise Error, "#{self.class} must define `@mutex = Mutex.new` in initialize method when including " \
                           "#{InstanceVariable}"
            end

            ivar = name.to_s.delete_prefix('@')

            @mutex.synchronize { instance_variable_set(:"@#{ivar}", value) }
          end
        end
      end
    end
  end
end
