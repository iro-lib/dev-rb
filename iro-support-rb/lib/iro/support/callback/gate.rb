# frozen_string_literal: true

module Iro
  module Support
    module Callback
      class Gate
        include Concurrent::InstanceVariable

        def initialize(**options, &callback)
          @callback = callback
          @mutex    = Mutex.new
          @resolved = false

          @condition = proc do |data|
            (options.key?(:if) ? options[:if].call(data) : true) &&
              !(options.key?(:unless) ? options[:unless].call(data) : false)
          end
        end

        def call(data)
          result = @callback.call(data)
          seen = Set.new

          while (result.is_a?(Gate) || result.is_a?(Proc)) && !seen.include?(result.object_id)
            seen << result.object_id
            result = result.call(data)
          end

          result
        end
        alias === call

        def resolve(data, with_lock: true)
          return false if resolved?
          return false unless @condition.call(data)

          with_lock ? concurrent_instance_variable_set(:resolved, true) : @resolved = true
          call(data)
          resolved?
        end

        def resolved?
          @resolved
        end
      end
    end
  end
end
