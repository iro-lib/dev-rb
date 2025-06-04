# frozen_string_literal: true

module Iro
  module Core
    module Coercion
      class << self
        private

        def included(base)
          super

          base.extend  Support::Concurrent::InstanceVariable
          base.extend  ClassMethods
          base.include InstanceMethods
        end
      end

      class Coercer
        def initialize(base)
          @base = base
          @coercions = EMPTY_ARRAY
          @mutex = Mutex.new
          register_coercion(@base) { |other| other }
        end

        def coerce(other)
          coercer = nil

          @coercions.each do |assertion, candidate|
            condition = Condition.new(**assertion.slice(:if, :unless))
            condition.if { |o| o.is_a?(assertion[:type]) } if assertion.key?(:type)

            if condition.satisfied?(other)
              coercer = candidate
              break
            end
          end

          raise CoercionError, "#{other} cannot be coerced to #{@base}" if coercer.nil?

          @base.instance_exec(other, &coercer)
        rescue StandardError => e
          raise e if e.is_a?(Error)

          raise CoercionError, "#{other} cannot be coerced to #{@base}: #{e.message}"
        end

        def dup_with_base(new_base)
          new_coercions = @coercions.map do |assertion, coercer|
            assertion = assertion.merge(type: new_base) if assertion.key?(:type) && assertion[:type] == @base
            [assertion, coercer]
          end

          dup.tap do |duped|
            duped.instance_variable_set(:@base, new_base)
            duped.instance_variable_set(:@coercions, new_coercions)
          end
        end

        def register_coercion(type = nil, **options, &coercer)
          assertion = { type: type, if: options[:if], unless: options[:unless] }.compact
          @mutex.synchronize { @coercions = @coercions.dup.push([assertion, coercer].freeze).freeze }
        end
      end

      module ClassMethods
        def coerce(other)
          coercer.coerce(other)
        end

        protected

        def coerce_from(...)
          coercer.register_coercion(...)
        end

        private

        def coercer
          concurrent_instance_variable_fetch(:coercer, Coercer.new(self))
        end

        def inherited(subclass)
          super

          subclass.instance_variable_set(:@coercer, coercer.dup_with_base(subclass))
        end
      end

      module InstanceMethods
        def coerce(other)
          self.class.coerce(other)
        end
      end
    end
  end
end
