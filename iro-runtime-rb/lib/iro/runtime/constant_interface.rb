# frozen_string_literal: true

module Iro
  module Runtime
    module ConstantInterface
      class << self
        def loaded?(name)
          !resolve(name).nil?
        end

        def resolve(name)
          name.delete_prefix('Iro::').split('::').reduce(Iro) do |accumulator, segment|
            break unless accumulator.autoload?(segment).nil? && accumulator.const_defined?(segment)

            accumulator.const_get(segment)
          end
        end
      end
    end
  end
end
