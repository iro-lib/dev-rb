# frozen_string_literal: true

module Iro
  module Support
    module ManagedAttributes
      class << self
        private

        def included(base)
          super

          base.extend  Concurrent::InstanceVariable
          base.extend  ClassMethods
          base.include Concurrent::InstanceVariable
          base.include InstanceMethods
        end
      end

      module ClassMethods
        def attributes
          concurrent_instance_variable_fetch(:attributes, EMPTY_HASH)
        end

        protected

        def alias_attribute(new_name, old_name)
          attribute = attributes[old_name].dup
          attribute.add_alias(new_name)
          attribute.freeze
          @mutex.synchronize { @attributes = attributes.merge(old_name => attribute) }

          alias_method new_name, old_name
          alias_method :"#{new_name}=", :"#{old_name}="
        end

        def attribute(name, type = Type::Anything, **)
          Iro.logger.warn('support') { "overriding attribute #{self}##{name}" } if attributes.key?(name)

          attribute = Attribute.new(name:, type:, **).freeze
          @attributes = attributes.merge(attribute.name => attribute)

          attr_reader attribute.name

          define_method(:"#{attribute.name}=") do |value|
            concurrent_instance_variable_set(attribute.name, process_attribute!(attribute.name, value))
          end
        end

        def validates(name, message, &)
          attribute = attributes[name].dup
          attribute.add_validation(message, &)
          attribute.freeze

          @mutex.synchronize { @attributes = attributes.merge(name => attribute) }
        end

        private

        def inherited(subclass)
          super

          subclass.instance_variable_set(:@attributes, EMPTY_HASH)
          attributes.each_value do |attribute|
            subclass.send(:attribute, attribute.name, attribute.type, **attribute.to_h.except(:name, :type))
          end
        end
      end

      module InstanceMethods
        protected

        def initialize_attributes!(**attributes)
          return if self.class.attributes.empty?

          self.class.attributes.each_key { |name| initialize_attribute!(name, attributes) }
        end

        private

        def initialize_attribute!(name, attributes)
          config = self.class.attributes[name]
          config ||= self.class.attributes.values.find { |attribute| attribute.aliases.include?(name) }

          return if instance_variable_defined?(:"@#{name}")

          config.dependencies.each { |dependency| initialize_attribute!(dependency, attributes) }

          key = attributes.key?(config.name) ? config.name : config.aliases.find { |k| attributes.key?(k) }
          value = process_attribute!(config.name, attributes[key])

          instance_variable_set(:"@#{name}", value)
        end

        def process_attribute!(name, value)
          attribute = self.class.attributes[name]

          default_or_value = if !value.nil?
                               value
                             elsif attribute.default.is_a?(Proc)
                               instance_exec(&attribute.default)
                             else
                               attribute.default
                             end

          raise ArgumentError, "#{attribute.name} cannot be nil" if default_or_value.nil? && attribute.required?
          return if default_or_value.nil? && !attribute.required?

          coerced_value = case attribute.coercer
                          when Proc   then instance_exec(default_or_value, &attribute.coercer)
                          when Symbol then send(attribute.coercer, default_or_value)
                          else default_or_value
                          end

          unless attribute.type === coerced_value
            raise TypeError,
                  "`#{attribute.name}` is invalid. Expected `#{attribute.type}`, got: `#{coerced_value.class}`"
          end

          attribute.validations.each do |validation, message|
            next if instance_exec(coerced_value, &validation)

            raise ArgumentError, "`#{attribute.name}` #{message}"
          end

          coerced_value
        end
      end
    end
  end
end
