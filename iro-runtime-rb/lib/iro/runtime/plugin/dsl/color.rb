# frozen_string_literal: true

module Iro
  module Runtime
    class Plugin
      class DSL
        class Color
          include Behavior

          def model(identifier, &definition)
            enhance_module('Iro::Model') do
              registry.register(identifier, &definition)
            end
          end

          def space(identifier, &space_class)
            enhance_module('Iro::Space') do
              registry.register(identifier, &space_class)
            end
          end
        end
      end
    end
  end
end
