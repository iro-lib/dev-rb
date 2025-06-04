# frozen_string_literal: true

module Iro
  module Model
    class Definition
      class DefineDSL
        def initialize(components, &block)
          @components = components

          block&.arity&.zero? ? instance_exec(&block) : (yield(self) if block)
        end

        def component(name, identifier, type, **options)
          @components.add(identifier:, name:, type:, **options.except(:identifier, :name, :type))
          self
        end
      end

      class ImplementDSL
        attr_reader :component_options

        def initialize(components, &block)
          @component_options = components.each_with_object({}) do |definition, hash|
            hash[definition.identifier] = definition.to_hash
          end

          block&.arity&.zero? ? instance_exec(&block) : (yield(self) if block)
        end

        def modify(identifier, **options)
          identifier_component_options = @component_options.fetch(identifier)

          if !options.key?(:display_format) && options.key?(:display_precision)
            options[:display_format] = identifier_component_options[:display_format].gsub(
              identifier_component_options[:display_precision].to_s,
              options[:display_precision].to_s,
            )
          end

          @component_options.fetch(identifier).merge!(options.except(:bounds, :identifier, :name, :type))
          self
        end
      end

      attr_reader :components
      attr_reader :identifier

      def initialize(identifier, &)
        @components = Component::Definition::Set.new
        @mutex      = Mutex.new
        @identifier = identifier

        DefineDSL.new(components, &)
      end

      def ===(other)
        components === other || super
      end

      def implement(base, &)
        unless base.is_a?(Class) && base < Iro::Model::Behavior
          raise Error, "#{base} does not include Iro::Model::Behavior"
        end

        component_options = ImplementDSL.new(components, &).component_options

        component_options.each_value do |options|
          component = base.components.add(**options)
          Component::MethodInjector.call(base, component)
        end

        self
      end
    end
  end
end
