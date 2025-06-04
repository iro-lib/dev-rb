# frozen_string_literal: true

module Iro
  module Reference
    module RGB
      COMPONENT_RANGE = 0.0..255.0

      STANDARD_FROM_LINEAR_TRANSFER_FUNCTION = proc do |component|
        if component <= 0.0031308
          component * 12.92
        else
          (1.055 * (component**(1.0 / 2.4))) - 0.055
        end
      end

      STANDARD_TO_LINEAR_TRANSFER_FUNCTION = proc do |component|
        if component <= 0.04045
          component / 12.92
        else
          ((component + 0.055) / 1.055)**2.4
        end
      end

      STANDARD_XYZ_TRANSFORM = Core::Matrix[
        [0.4124564, 0.3575761, 0.1804375],
        [0.2126729,  0.7151522,  0.0721750],
        [0.0193339,  0.1191920,  0.9503041],
      ]
    end
  end
end
