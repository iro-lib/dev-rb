# frozen_string_literal: true

module Iro
  module Model
    module Component
      module Definition
        class Set
          include Enumerable

          TYPES = {
            circular: [Circular, EMPTY_HASH].freeze,
            hue_angle: [Circular, { bounds: 0.0..360.0, display_format: '%.0f°' }.freeze].freeze,
            linear: [Linear, EMPTY_HASH].freeze,
            opponent: [Opponent, EMPTY_HASH].freeze,
            percentage: [
              Linear,
              { bounds: PERCENTAGE_RANGE, differential_step: 0.005, display_format: '%.1f%%' }.freeze,
            ].freeze,
          }.freeze

          def initialize
            @entries = EMPTY_HASH
            @index   = EMPTY_HASH
            @mutex   = Mutex.new
          end

          def ==(other)
            other.is_a?(self.class) && identifiers == other.identifiers && map == other.map
          end

          def ===(other)
            (other.is_a?(Array) && valid?(*other)) || (
              other.class.respond_to?(:components) &&
                other.class.components.is_a?(self.class) &&
                other.respond_to?(:components) &&
                other.components.is_a?(Component::Set) &&
                valid?(*other.components.to_denormalized)
            ) || super
          end

          def [](identifier_name_or_index)
            case identifier_name_or_index
            when String, Symbol
              key = identifier_name_or_index
              @entries.fetch(key, @entries[@index[key]])
            when Integer
              @entries.values[identifier_name_or_index]
            end
          end

          def add(type:, **options)
            definition_class, default_options = TYPES[type]

            unless definition_class
              raise ArgumentError, "`:type` is invalid. Expected one of #{TYPES.keys.join(', ')}, got: `#{type}`"
            end

            options     = default_options.merge(options)
            definition  = definition_class.new(**options)
            identifier  = definition.identifier
            name        = definition.name
            new_entries = @entries.merge(identifier => definition.freeze).freeze
            new_index   = identifier == name ? @index : @index.merge(name => identifier)
            method_proc = -> { @entries[identifier] }

            @mutex.synchronize do
              @entries = new_entries
              @index   = new_index

              define_singleton_method(definition.identifier, &method_proc)
              define_singleton_method(definition.name, &method_proc) unless identifier == name
            end

            definition
          end

          def count(&)
            @entries.values.count(&)
          end

          def each(&)
            return enum_for(:each) unless block_given?

            @entries.each_value(&)
            self
          end
          alias each_definition each

          def each_identifier(&)
            return enum_for(:each_identifier) unless block_given?

            @entries.each_key(&)
            self
          end

          def each_pair(&)
            return enum_for(:each_pair) unless block_given?

            @entries.each_pair(&)
            self
          end

          def identifiers
            @entries.keys
          end

          def names
            @index.keys
          end

          def size
            @entries.size
          end
          alias length size

          def valid?(*components)
            return false if components.size < count(&:required?)

            map.with_index do |definition, index|
              value = components[index]
              next true if value.nil? && !definition.required?
              next false unless value.is_a?(Numeric)
              next true if definition.boundary.unbound?

              definition.boundary.range.cover?(value)
            end.all?
          end
        end
      end
    end
  end
end
