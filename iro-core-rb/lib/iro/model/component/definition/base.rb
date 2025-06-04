# frozen_string_literal: true

module Iro
  module Model
    module Component
      module Definition
        class Base
          Boundary = Struct.new(:center, :maximum, :minimum, :range, :width, keyword_init: true) do
            alias_method :max, :maximum
            alias_method :min, :minimum

            def bound?
              minimum.finite? && maximum.finite?
            end

            def unbound?
              !bound?
            end
          end

          Display = Struct.new(:format, :precision, keyword_init: true)

          attr_reader :boundary
          attr_reader :differential_step
          attr_reader :display
          attr_reader :identifier
          attr_reader :name
          attr_reader :type

          def initialize(identifier:, name:, bounds: nil, differential_step: 1, display_format: nil,
                         display_precision: 0, optional: false)
            @boundary = begin
              maximum = bounds&.end&.to_f || Float::INFINITY
              minimum = bounds&.begin&.to_f || -Float::INFINITY

              center = bounds.nil? || (bounds.begin.infinite? && bounds.end.infinite?) ? 0.0 : (maximum + minimum) / 2.0
              range  = minimum..maximum
              width  = maximum - minimum

              Boundary.new(center:, maximum:, minimum:, range:, width:)
            end
            @differential_step = differential_step
            @display = Display.new(format: display_format || "%.#{display_precision}f", precision: display_precision)
            @identifier = identifier.to_sym
            @name = name.to_sym
            @required = !optional
            @type = Support::Inflection.snake_case(self.class.name.split('::').last).to_sym
          end

          def ==(other)
            other.is_a?(self.class) && other.boundary == boundary && other.identifier == identifier &&
              other.required? == required?
          end

          def clamp(value)
            return value if boundary.unbound?

            denormalized = denormalize(value)
            if denormalized > boundary.maximum
              normalize(boundary.maximum)
            elsif denormalized < boundary.minimum
              normalize(boundary.minimum)
            else
              value
            end
          end

          def required?
            @required
          end

          def to_hash
            {
              bounds: boundary.range,
              differential_step: differential_step,
              display_format: display.format,
              display_precision: display.precision,
              identifier: identifier,
              name: name,
              optional: !required?,
              type: type,
            }
          end
          alias to_h to_hash
        end
      end
    end
  end
end
