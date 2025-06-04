# frozen_string_literal: true

module Iro
  class Chromaticity
    module Transform
      module XYZToXY
        class << self
          def call(xyz, **_options)
            x, y, = components = xyz.to_a
            sum   = components.sum

            if sum.zero?
              [0.0, 0.0]
            else
              [x / sum, y / sum]
            end
          end
        end
      end
    end
  end
end
