# frozen_string_literal: true

module Iro
  module Space
    class Registry < Support::Concurrent::Registry
      lazy_load_values

      def register(identifier, &space_class)
        raise ArgumentError, "#{identifier} is already a registered space" if exist?(identifier)

        method_proc = ->(*components, **options) { color(identifier, *components, **options) }

        Function.const_get(:MUTEX).synchronize do
          Function.define_singleton_method(identifier, &method_proc)
          Function.define_method(identifier, &method_proc)
        end

        Iro.logger.debug('space') { "color space #{identifier} registered" }
        Support::Callback.resolve(type: :space_registered, identifier:)

        super(identifier, space_class)
      end
    end
  end
end
