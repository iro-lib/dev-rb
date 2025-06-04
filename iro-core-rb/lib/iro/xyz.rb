# frozen_string_literal: true

module Iro
  class XYZ
    include Space::Behavior

    implements Model::XYZ do
      modify :x, display_precision: 8, differential_step: 0.001
      modify :y, display_precision: 8, differential_step: 0.001
      modify :z, display_precision: 8, differential_step: 0.001
    end

    use_context Space::Context::SimpleReferenceWhite

    categorized_as :physiological
  end
end
