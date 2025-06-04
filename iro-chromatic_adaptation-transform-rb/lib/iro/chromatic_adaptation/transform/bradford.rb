# frozen_string_literal: true

module Iro
  module ChromaticAdaptation
    class Transform
      class Bradford < Transform
        transform(
          [0.8951, 0.2664, -0.1614],
          [-0.7502, 1.7135, 0.0367],
          [0.0389, -0.0685, 1.0296],
        )
      end
    end
  end
end
