# frozen_string_literal: true

module Iro
  module Runtime
    class Plugin
      class DSL
        class Configuration
          include Behavior

          def setting(name, default_value = nil, &default_proc)
            enhance_module('Iro::Configuration') do
              setting(name, default_value, &default_proc)
            end
          end

          def validate_setting(name, message, &validator)
            enhance_module('Iro::Configuration') do
              validates(name, message, &validator)
            end
          end
        end
      end
    end
  end
end
