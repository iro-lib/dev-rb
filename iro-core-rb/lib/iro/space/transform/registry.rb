# frozen_string_literal: true

module Iro
  module Space
    module Transform
      class Registry
        include Support::Concurrent::InstanceVariable

        def initialize
          @mutex      = Mutex.new
          @entries    = EMPTY_HASH
          @path_index = EMPTY_HASH
          @weights    = EMPTY_HASH
        end

        def compose(from, to)
          path = find_quickest_path(from, to)
          return unless path

          transforms = path.each_cons(2).map { |a, b| find(a, b) }
          lambda do |color, **options|
            transforms.reduce(color) { |accumulator, transform| transform.call(accumulator, **options) }
          end
        end

        def exist?(from, to)
          @entries.key?(build_key(from, to))
        end

        def find(from, to)
          key = build_key(from, to)
          found = @entries[key]
          return unless found

          if found.is_a?(Proc)
            found = found.call

            new_entries = @entries.merge(key => found).freeze
            new_weights = @weights.merge(key => estimate_cost(found)).freeze

            concurrent_instance_variable_set(:entries, new_entries)
            concurrent_instance_variable_set(:weights, new_weights)
          end

          found
        end

        def find_quickest_path(from, to)
          return @path_index[[from, to]] if @path_index.key?([from, to])
          return [from, to] if exist?(from, to)

          costs = Hash.new(Float::INFINITY)
          prev  = {}
          costs[from] = 0
          queue = [[0, from]]

          until queue.empty?
            current_cost, current = queue.shift
            break if current == to

            neighbors(current).each do |neighbor|
              edge_key = build_key(current, neighbor)
              next unless @weights[edge_key]

              cost = @weights[edge_key]
              new_cost = current_cost + cost

              next unless new_cost < costs[neighbor]

              costs[neighbor] = new_cost
              prev[neighbor] = current
              queue << [new_cost, neighbor]
            end

            queue.sort_by!(&:first)
          end

          return nil unless prev.key?(to)

          path = [to]
          path.unshift(prev[path.first]) until path.first == from

          new_path_index = @path_index.merge([from, to] => path).freeze
          concurrent_instance_variable_set(:path_index, new_path_index)

          path
        end

        def list
          @entries.keys.map { |key| key.to_s.split('_to_').map(&:to_sym) }
        end

        def register(from, to, &transform_module)
          key = build_key(from, to)
          new_entries = @entries.merge(key => transform_module).freeze
          result = concurrent_instance_variable_set(:entries, new_entries)

          Iro.logger.debug { "space transform registered: #{from} -> #{to}" }
          Support::Callback.resolve(type: :space_transform_registered, from:, to:)
          result
        end

        private

        def build_key(from, to)
          :"#{from}_to_#{to}"
        end

        def estimate_cost(entry)
          RubyVM::InstructionSequence.of(entry.method(:call)).to_a.flatten.size.to_f / 100
        rescue StandardError
          1.0
        end

        def neighbors(space)
          list.select { |from, _to| from == space }.map(&:last)
        end
      end
    end
  end
end
