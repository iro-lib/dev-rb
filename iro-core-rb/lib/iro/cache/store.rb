# frozen_string_literal: true

module Iro
  module Cache
    class Store
      def initialize(**)
        @mutex = Mutex.new
        @store = EMPTY_HASH
      end

      def [](...)
        read(...)
      end

      def []=(...)
        write(...)
      end

      def clear
        @store.clear
      end

      def count(&)
        @store.values.count(&)
      end

      def fetch(*key_parts)
        key = generate_key(key_parts)
        return read_by_key(key) if @store.key?(key)

        write_by_key(key, yield)
        read_by_key(key)
      end

      def size
        @store.size
      end
      alias length size

      protected

      def deep_freeze(value)
        if value.is_a?(Array)
          value.map { |v| deep_freeze(v) }.freeze
        elsif value.is_a?(Hash)
          value.transform_keys { |k| deep_freeze(k) }.transform_values { |v| deep_freeze(v) }.freeze
        elsif value.respond_to?(:freeze)
          value.freeze
        else
          value
        end
      end

      def generate_key(key_parts)
        Identity.generate(key_parts)
      end

      def read(*key_parts)
        read_by_key(generate_key(key_parts))
      end

      def read_by_key(key)
        @store[key]
      end

      def write(*key_parts, value)
        write_by_key(generate_key(key_parts), value)
      end

      def write_by_key(key, value)
        new_store = @store.merge(key => value).freeze
        @mutex.synchronize { @store = new_store }
      end
    end
  end
end
