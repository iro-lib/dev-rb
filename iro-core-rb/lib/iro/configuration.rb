# frozen_string_literal: true

module Iro
  class Configuration
    extend  Support::Concurrent::InstanceVariable
    include Support::Concurrent::InstanceVariable

    Default = Struct.new(:value, :validations, keyword_init: true)

    class << self
      def defaults
        concurrent_instance_variable_fetch(:defaults, EMPTY_HASH)
      end

      protected

      def setting(name, default_value = nil, &default_proc)
        value        = default_value ? -> { default_value } : default_proc
        default      = Default.new(value: value, validations: EMPTY_ARRAY).freeze
        new_defaults = defaults.merge(name => default.freeze).freeze

        @mutex.synchronize do
          @defaults = new_defaults

          define_method(:"default_#{name}") do
            ivar = instance_variable_get("@default_#{name}")
            return ivar unless ivar.is_a?(Default)

            instance_exec(&ivar.value)
          end

          define_method(:"set_default_#{name}") do |new_value|
            self.class.default[name].validations.each do |validator, message|
              raise ConfigurationError, "`#{name}` #{message}" unless instance_exec(new_value, &validator)
            end

            concurrent_instance_variable_set("@default_#{name}", new_value)
          end
        end
      end

      def validates(name, message, &validator)
        default = defaults[name].dup
        default.validations = default.validations.dup.push([validator, message].freeze)
        new_defaults = defaults.merge(name => default.freeze).freeze
        @mutex.synchronize { @defaults = new_defaults }
      end
    end

    setting(:cache_options, { max_size: 2_048_000 })

    setting(:cache_store) { Cache::LRUStore }

    setting(:reference_white) { Reference::White::D65 }

    validates :cache_options, 'must be a `Hash[Symbol, Object]`' do |options|
      options.is_a?(Hash) && options.keys.all?(Symbol)
    end

    validates :cache_store, 'must be a `Class < Iro::Cache::Store`' do |store|
      store.is_a?(Class) && store < Cache::Store
    end

    validates :reference_white, 'must be `[Numeric, Numeric, Numeric]`' do |white|
      array = white.to_a
      array.is_a?(Array) && array.size == 3 && array.all?(Numeric)
    end

    def initialize
      self.class.defaults.each_pair { |name, default| instance_variable_set(:"@default_#{name}", default) }
    end

    def disable_cache
      set_default_cache_options({})
      set_default_cache_store(Cache::NullStore)

      Iro.send(:concurrent_instance_variable_set, :cache, nil)
    end

    def enable_cache(options: nil, store: nil)
      options ||= self.class.defaults[:cache_options].value.call
      store   ||= self.class.defaults[:cache_store].value.call

      set_default_cache_options(options)
      set_default_cache_store(store)

      Iro.send(:concurrent_instance_variable_set, :cache, store.new(**options))
    end
  end
end
