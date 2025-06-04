# frozen_string_literal: true

module Iro
  module Support
    module Type
      module Anything
        class << self
          def ===(_)
            true
          end

          def to_s
            'Anything'
          end
          alias inspect to_s
        end
      end
    end
  end
end
