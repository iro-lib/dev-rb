# frozen_string_literal: true

module Iro
  module Space
    class Context
      extend  Support::Concurrent::InstanceVariable
      include Support::Concurrent::InstanceVariable
      include Support::ManagedAttributes

      ComputedAttribute = Struct.new(:allow_override, :callback, :name, keyword_init: true)

      class << self
        def adaptation_callback
          concurrent_instance_variable_fetch(:adaptation_callback) do
            ->(color) { color }
          end
        end

        def computed_attributes
          concurrent_instance_variable_fetch(:computed_attributes, EMPTY_HASH)
        end

        protected

        def compute_attribute(name, allow_override: false, &callback)
          name = name.to_sym
          attr_reader name

          attribute = ComputedAttribute.new(allow_override:, name:, callback: callback)
          new_computed_attributes = computed_attributes.merge(name => attribute.freeze).freeze
          concurrent_instance_variable_set(:computed_attributes, new_computed_attributes)
        end

        def on_adaptation(&callback)
          concurrent_instance_variable_set(:adaptation_callback, callback)
        end
      end

      def initialize(**)
        @mutex = Mutex.new
        initialize_attributes!(**)
        initialize_computed_attributes(**)
      end

      def ==(other)
        other.class < Context && to_hash == other.to_hash
      end

      def adapt(color)
        instance_exec(color, &self.class.adaptation_callback)
      end

      def to_hash
        self.class.attributes.keys.each_with_object({}) do |attribute, hash|
          hash[attribute] = instance_variable_get(:"@#{attribute}")
        end
      end
      alias to_h to_hash

      def with(**attributes)
        context_attributes = attributes.slice(*self.class.attributes.keys)
        computed_overrides = attributes.except(*self.class.attributes.keys)

        processed_attributes = context_attributes.each_with_object({}) do |(name, value), hash|
          hash[name] = process_attribute!(name, value)
        end

        as_hash = to_hash
        processed_attributes = as_hash.merge(processed_attributes)
        return self if processed_attributes == as_hash

        dup.tap do |duped|
          processed_attributes.each_pair do |attribute, value|
            duped.instance_variable_set(:"@#{attribute}", value)
            duped.send(:initialize_computed_attributes, **computed_overrides)
          end
        end
      end

      private

      def initialize_computed_attributes(**attributes)
        self.class.computed_attributes.each_pair do |name, config|
          if attributes.key?(name) && config.allow_override
            instance_variable_set(:"@#{name}", attributes[name])
          else
            instance_variable_set(:"@#{name}", instance_exec(&config.callback))
          end
        end
      end
    end
  end
end
