# frozen_string_literal: true

module Iro
  module Support
    module Callback
      class Queue
        include Enumerable
        include Concurrent::InstanceVariable

        def initialize
          @entries = EMPTY_ARRAY
          @mutex   = Mutex.new
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
          new_entries = @entries.dup.push(future).freeze
          concurrent_instance_variable_set(:entries, new_entries)
          resolve(EMPTY_HASH)
        end

        def resolve(data, with_lock: true)
          to_process = reject(&:resolved?)

          Iro.logger.debug('runtime') { "resolving #{to_process.size} futures with data: #{data}" }

          if with_lock
            @mutex.synchronize { to_process.each { |gate| gate.resolve(data, with_lock:) } }
          else
            to_process.each { |gate| gate.resolve(data, with_lock:) }
          end

          compact!(with_lock:)
        end

        private

        def compact!(with_lock: true)
          new_entries = reject(&:resolved?).freeze

          Iro.logger.debug('runtime') { "removing #{size - new_entries.size} resolved futures" }

          with_lock ? concurrent_instance_variable_set(:entries, new_entries) : @entries = new_entries
          self
        end
      end
    end
  end
end
