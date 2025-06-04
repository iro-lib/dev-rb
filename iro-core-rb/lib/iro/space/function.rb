# frozen_string_literal: true

module Iro
  module Space
    module Function
      MUTEX = Mutex.new
      private_constant :MUTEX

      module_function

      def color(identifier, ...)
        space = Space.registry[identifier]
        raise ArgumentError, "unknown color space #{identifier}" unless space

        space.new(...)
      end
    end
  end
end
