# frozen_string_literal: true

module Iro
  module Model
    class Registry < Support::Concurrent::Registry
      def register(identifier, &)
        return find(identifier) if exist?(identifier)

        model         = Definition.new(identifier, &)
        constant_name = identifier.upcase

        Model.instance_variable_get(:@mutex).synchronize { Model.const_set(constant_name, model) }

        Iro.logger.debug('model') { "model #{identifier} registered" }
        Support::Callback.resolve(type: :model_registered, identifier:, model:)

        super(identifier, model)
      end
    end
  end
end
