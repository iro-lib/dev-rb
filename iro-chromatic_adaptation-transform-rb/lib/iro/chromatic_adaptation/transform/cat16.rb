# frozen_string_literal: true

module Iro
  module ChromaticAdaptation
    class Transform
      class CAT16 < Transform
        transform(
          [0.401288, 0.650173, -0.051461],
          [-0.250268, 1.204414, 0.045854],
          [-0.002079, 0.048952, 0.953127],
        )
      end
    end
  end
end
