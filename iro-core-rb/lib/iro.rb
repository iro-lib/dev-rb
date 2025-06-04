# frozen_string_literal: true

module Iro
  FRACTION_RANGE = 0.0..1.0
  private_constant :FRACTION_RANGE

  PERCENTAGE_RANGE = 0.0..100.0
  private_constant :PERCENTAGE_RANGE

  extend Space::Function

  class << self
    def cache
      config

      concurrent_instance_variable_fetch(:cache) do
        config.default_cache_store.new(**config.default_cache_options)
      end
    end

    def config
      concurrent_instance_variable_fetch(:config, Configuration.new)
    end

    def configure(&block)
      block&.arity&.zero? ? config.instance_exec(&block) : (yield(config) if block)
    end
  end
end

def Iro(...) # rubocop:disable Naming/MethodName
  Iro::Space::Function.color(...)
end
