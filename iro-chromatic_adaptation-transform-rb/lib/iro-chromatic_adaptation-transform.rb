# frozen_string_literal: true

require 'iro-core'
require 'iro-runtime'
require 'iro-support'

root_path = File.dirname(__FILE__)

Iro.plug('iro-chromatic_adaptation-transform', root_path) do
  loader do
    inflect(
      'cat' => 'CAT',
      'cat02' => 'CAT02',
      'cat16' => 'CAT16',
      'cat97' => 'CAT97',
      'cat2000' => 'CAT2000',
      'cmc' => 'CMC',
      'hpe' => 'HPE',
      'lms_to_xyz' => 'LMSToXYZ',
      'xyz_scaling' => 'XYZScaling',
      'xyz_to_lms' => 'XYZToLMS',
    )
  end

  configuration do
    setting(:chromatic_adaptation_transform) { Iro::ChromaticAdaptation::Transform::CAT16 }
    setting(:cone_transform) { Iro::ChromaticAdaptation::Transform::HuntPointerEstevez }

    validate_setting :chromatic_adaptation_transform, 'must be a `Iro::ChromaticAdaptation::Transform`' do |cat|
      cat.is_a?(Iro::ChromaticAdaptation::Transform)
    end

    validate_setting :cone_transform, 'must be a `Iro::ChromaticAdaptation::Transform`' do |cat|
      cat.is_a?(Iro::ChromaticAdaptation::Transform)
    end
  end

  enhance_module('Iro::Configuration') do
    alias_method :default_cat, :default_chromatic_adaptation_transform
    alias_method :set_default_cat, :set_default_chromatic_adaptation_transform
  end

  enhance_module('Iro::Space::Context') do
    attribute :chromatic_adaptation_transform, Iro::ChromaticAdaptation::Transform,
              default: -> { Iro.config.default_chromatic_adaptation_transform }
    alias_attribute :cat, :chromatic_adaptation_transform

    attribute :cone_transform, Iro::ChromaticAdaptation::Transform,
              default: -> { Iro.config.default_cone_transform }
  end

  color do
    transform(:lms, :xyz) { Iro::ChromaticAdaptation::Extension::Transform::LMSToXYZ }
    transform(:xyz, :lms) { Iro::ChromaticAdaptation::Extension::Transform::XYZToLMS }
  end
end
