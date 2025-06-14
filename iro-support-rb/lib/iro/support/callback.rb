# frozen_string_literal: true

module Iro
  module Support
    module Callback
      extend Concurrent::InstanceVariable

      class << self
        def new(...)
          gate = Gate.new(...)
          queue.push(gate)
          gate
        end

        def resolve(**data)
          queue.resolve(data)
        end

        private

        def queue
          concurrent_instance_variable_fetch(:queue, Queue.new)
        end
      end
    end
  end
end
