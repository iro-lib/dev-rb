# frozen_string_literal: true

module Iro
  module Model
    module Component
      class Set
        include Enumerable

        def initialize(base, *components, normalized: false)
          @base    = base
          @entries = EMPTY_ARRAY
          @mutex   = Mutex.new

          @base.class.components.each_with_index do |definition, index|
            value = components[index]

            @entries = @entries.dup.push(normalized ? value : definition.normalize(value)).freeze

            identifier = definition.identifier
            name       = definition.name

            define_singleton_method(identifier) { @entries[index] }

            next if identifier == name

            define_singleton_method(name) do
              value = @entries[index]
              return unless value

              definition.denormalize(value).round(definition.display.precision)
            end
          end
        end

        def ==(other)
          (
            other.is_a?(self.class) &&
              other.instance_variable_get(:@base).class == @base.class &&
              to_denormalized == other.to_denormalized
          ) ||
            (other.is_a?(Array) && to_denormalized == other) ||
            (other.is_a?(Array) && to_normalized == other)
        end

        def [](identifier_name_or_index)
          case identifier_name_or_index
          when String, Symbol
            public_send(identifier_name_or_index.to_sym)
          when Integer
            @entries[identifier_name_or_index]
          end
        end

        def each(&)
          return enum_for(:each) unless block_given?

          @entries.each(&)
          self
        end

        alias to_array to_a

        def to_denormalized
          @base.class.components.map.with_index do |definition, index|
            value = @entries[index]
            next unless value

            definition.denormalize(value).round(definition.display.precision)
          end
        end

        def to_denormalized_hash
          @base.class.components.each_with_object({}).with_index do |(definition, hash), index|
            value = @entries[index]

            hash[definition.identifier] = definition.denormalize(value).round(definition.display.precision)
          end
        end
        alias to_hash to_denormalized_hash
        alias to_h    to_denormalized_hash

        alias to_normalized to_a

        def to_normalized_hash
          @base.class.components.each_with_object({}).with_index do |(definition, hash), index|
            hash[definition.identifier] = @entries[index]
          end
        end

        def to_string
          @base.class.components.map.with_index do |definition, index|
            value = @entries[index]
            value ? definition.display.format % definition.denormalize(value) : nil
          end.compact.join(', ')
        end
        alias inspect to_string
        alias to_s    to_string

        def valid?
          @base.class.components.valid?(*to_denormalized)
        end
      end
    end
  end
end
