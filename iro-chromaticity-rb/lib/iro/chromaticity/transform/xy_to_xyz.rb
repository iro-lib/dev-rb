# frozen_string_literal: true

module Iro
  class Chromaticity
    module Transform
      module XYToXYZ
        class << self
          def call(xy, **options)
            reference_white = options.fetch(:reference_white, Iro.config.default_reference_white)
            luminance       = reference_white.to_a[1].to_f
            x, y            = xy.to_a

            if y.zero?
              [0.0, 0.0, 0.0]
            else
              [(x / y) * luminance, luminance, ((1.0 - x - y) / y) * luminance]
            end
          end
        end
      end
    end
  end
end
