# frozen_string_literal: true

module Iro
  module ChromaticAdaptation
    class Transform
      class Fairchild < Transform
        transform(
          [0.8562, 0.3372, -0.1934],
          [-0.8360, 1.8327, 0.0033],
          [0.0357, -0.0469, 1.0112],
        )
      end
    end
  end
end
