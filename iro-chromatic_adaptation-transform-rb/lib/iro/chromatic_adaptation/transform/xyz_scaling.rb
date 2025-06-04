# frozen_string_literal: true

module Iro
  module ChromaticAdaptation
    class Transform
      class XYZScaling < Transform
        transform(
          [1.0, 0.0, 0.0],
          [0.0, 1.0, 0.0],
          [0.0, 0.0, 1.0],
        )
      end
    end
  end
end
