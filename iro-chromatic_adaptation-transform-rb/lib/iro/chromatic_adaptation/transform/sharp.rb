# frozen_string_literal: true

module Iro
  module ChromaticAdaptation
    class Transform
      class Sharp < Transform
        transform(
          [1.2694, -0.0988, -0.1706],
          [-0.8364, 1.8006, 0.0357],
          [0.0297, -0.0315, 1.0018],
        )
      end
    end
  end
end
