# frozen_string_literal: true

module Iro
  module Support
    module Callback
      class Queue
        include Enumerable
        include Concurrent::InstanceVariable

        def initialize
          @entries = []
        end

        def each(&)
          return enum_for(:each) unless block_given?

          @entries.each(&)
          self
        end

        def length
          @entries.length
        end
        alias size length

        def push(future)
          new_entries = @entries.push(future)
          @entires = new_entries
          resolve(EMPTY_HASH)
        end

        def resolve(data)
          to_process = reject(&:resolved?)
          Iro.logger.debug('runtime') { "resolving #{to_process.size} futures with data: #{data}" }
          to_process.each { |gate| gate.resolve(data) }

          compact!
        end

        private

        def compact!
          new_entries = reject(&:resolved?)
          Iro.logger.debug('runtime') { "removing #{size - new_entries.size} resolved futures" }
          @entries = new_entries

          self
        end
      end
    end
  end
end
