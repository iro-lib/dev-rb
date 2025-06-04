# frozen_string_literal: true

module Iro
  module Support
    module Callback
      class Gate
        include Concurrent::InstanceVariable

        def initialize(**options, &callback)
          @callback = callback
          @resolved = false

          @condition = proc do |data|
            (options.key?(:if) ? options[:if].call(data) : true) &&
              !(options.key?(:unless) ? options[:unless].call(data) : false)
          end
        end

        def call(data)
          @callback.call(data)
        end
        alias === call

        def resolve(data)
          return false if resolved?
          return false unless @condition.call(data)

          @resolved = true
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
