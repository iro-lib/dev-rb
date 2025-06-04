# frozen_string_literal: true

module Iro
  class LMS
    include Space::Behavior

    implements Model::LMS do
      modify :l, display_precision: 8, differential_step: 0.005
      modify :m, display_precision: 8, differential_step: 0.005
      modify :s, display_precision: 8, differential_step: 0.005
    end

    use_context Space::Context::SimpleReferenceWhite

    categorized_as :physiological
  end
end
