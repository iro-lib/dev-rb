# frozen_string_literal: true

module Iro
  module Runtime
    class Plugin
      class DSL
        class Loader
          include Behavior

          def eager_load_directories
            @plugin.eager_load_directories
          end
          alias eager_load_dirs eager_load_directories

          def inflect(...)
            @plugin.loader.inflector.inflect(...)
          end

          private

          def method_missing(method, ...)
            return super unless respond_to_missing?(method)

            @plugin.loader.public_send(method, ...)
          end

          def respond_to_missing?(method, include_private = false)
            @plugin.loader.respond_to?(method) || super
          end
        end
      end
    end
  end
end
