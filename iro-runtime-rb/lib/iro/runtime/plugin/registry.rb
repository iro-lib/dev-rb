# frozen_string_literal: true

module Iro
  module Runtime
    class Plugin
      class Registry < Support::Concurrent::Registry
        def register(name, root_path = nil, &)
          if exist?(name)
            plugin = find(name)

            DSL.new(plugin, &)
            plugin.reload

            Iro.logger.debug { "replugged plugin #{name}" }

            return plugin
          end

          raise ArgumentError, '`root_path` is required on initial plugin registration' unless root_path

          plugin = Plugin.new(name:, root_path:)
          DSL.new(plugin, &)
          plugin.setup

          Iro.logger.debug { "registered plugin #{name}" }

          super(name, plugin)
        end
      end
    end
  end
end
