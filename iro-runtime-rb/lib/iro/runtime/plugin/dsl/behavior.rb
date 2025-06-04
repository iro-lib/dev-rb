# frozen_string_literal: true

module Iro
  module Runtime
    class Plugin
      class DSL
        module Behavior
          def initialize(plugin, &block)
            @plugin = plugin

            block&.arity&.zero? ? instance_exec(&block) : (yield(self) if block)
          end

          def enhance_module(module_name, &)
            on_load(module_name) { ModuleEnhancer.new(Runtime.constant.resolve(module_name), &) }
          end

          def on_load(module_name, **options, &)
            condition = proc do |data|
              Runtime.constant.loaded?(module_name) &&
                (options.key?(:if) ? options[:if].call(data) : true) &&
                !(options.key?(:unless) ? options[:unless].call(data) : false)
            end

            on_plugin(@plugin.name) { Support::Callback.new(if: condition, &) }
          end

          def on_plugin(plugin_name, **options, &)
            condition = proc do |data|
              Runtime.plugin.exist?(plugin_name) &&
                (options.key?(:if) ? options[:if].call(data) : true) &&
                !(options.key?(:unless) ? options[:unless].call(data) : false)
            end

            Support::Callback.new(if: condition, &)
          end
        end
      end
    end
  end
end
