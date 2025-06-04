# frozen_string_literal: true

module Iro
  module Support
    module Concurrent
      class Registry
        extend  Concurrent::InstanceVariable
        include Concurrent::InstanceVariable

        class << self
          protected

          def lazy_load_values
            concurrent_instance_variable_set(:@lazy_load_values, true)

            @mutex.synchronize do
              define_method(:loaded?) do |key|
                return false unless exist?(key)

                !@entries.fetch(key, @entries[(@index || EMPTY_HASH)[key]]).is_a?(Proc)
              end
            end
          end

          def with_index
            concurrent_instance_variable_set(:@with_index, true)

            @mutex.synchronize do
              define_method(:index_on) do |index, key|
                raise ArgumentError, "index key `:#{index}` conflicts with existing entry key" if @entries.key?(index)
                raise ArgumentError, "index key `:#{index}` already exists" if @index.key?(index)
                raise ArgumentError, "cannot index on unknown key `:#{key}`" unless @entries.key?(key)

                @index[index] = key
              end
            end
          end
        end

        def initialize
          @mutex   = Mutex.new
          @entries = EMPTY_HASH

          return unless self.class.instance_variable_get(:@with_index)

          @index = EMPTY_HASH
        end

        def exist?(key)
          if self.class.instance_variable_get(:@with_index)
            @entries.key?(key) || @index.key?(key)
          else
            @entries.key?(key)
          end
        end

        def find(key)
          found = if self.class.instance_variable_get(:@with_index)
                    @entries.fetch(key, @entries[@index[key]])
                  else
                    @entries[key]
                  end
          return unless found

          if self.class.instance_variable_get(:@lazy_load_values)
            found.call if found.is_a?(Proc)
          else
            found
          end
        end
        alias [] find

        def list
          if self.class.instance_variable_get(:@with_index)
            (@entries.keys + @index.keys).sort
          else
            @entries.keys.sort
          end
        end

        def register(key, value)
          @mutex.synchronize { @entries = @entries.merge(key => value) }
        end
      end
    end
  end
end
