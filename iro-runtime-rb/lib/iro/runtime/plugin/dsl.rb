# frozen_string_literal: true

module Iro
  module Runtime
    class Plugin
      class DSL
        include Behavior

        def color(&)
          Color.new(@plugin, &)
        end

        def configuration(&)
          Configuration.new(@plugin, &)
        end

        def loader(&)
          Loader.new(@plugin, &)
        end
      end
    end
  end
end
