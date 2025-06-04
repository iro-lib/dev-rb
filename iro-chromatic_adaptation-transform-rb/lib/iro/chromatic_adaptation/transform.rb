# frozen_string_literal: true

module Iro
  module ChromaticAdaptation
    class Transform
      extend Support::Concurrent::InstanceVariable

      class << self
        attr_reader :matrix

        def ===(other)
          other.is_a?(Transform) || super
        end

        def adapt(xyz, **options)
          unless Model::XYZ === xyz
            raise TypeError, '`xyz` is invalid. Expected an object that implements `XYZ` components or ' \
                             "`[Numeric, Numeric, Numeric]` got: #{xyz.inspect}"
          end

          reference_white = options.fetch(
            :reference_white,
            xyz.respond_to?(:context) ? xyz.context.reference_white : nil,
          )
          reference_white ||= Iro.config.default_reference_white

          unless Model::XYZ === reference_white
            raise TypeError, '`:reference_white` is invalid. Expected an object that implements `XYZ` components or ' \
                             "`[Numeric, Numeric, Numeric]` got: #{reference_white.inspect}"
          end

          target_white = options.fetch(:target_white)

          unless Model::XYZ === target_white
            raise TypeError, '`:target_white` is invalid. Expected an object that implements `XYZ` components or ' \
                             "`[Numeric, Numeric, Numeric]` got: #{target_white.inspect}"
          end

          xyz = XYZ.coerce(xyz)
          reference_white = XYZ.coerce(reference_white)
          target_white = XYZ.coerce(target_white)

          xyz = Iro.cache.fetch(self, :adapt, xyz, reference_white, target_white) do
            lms = xyz.to_lms(as_values: true)
            reference_white_lms = reference_white.to_lms(as_values: true)
            target_white_lms = target_white.to_lms(as_values: true)

            adapted_lms = lms.map.with_index do |value, i|
              value * (target_white_lms[i] / reference_white_lms[i])
            end

            LMS.coerce(adapted_lms).to_xyz(as_values: true).to_a
          end

          if options.fetch(:as_values, false)
            xyz
          else
            XYZ.from_intermediate(
              *xyz, reference_white: target_white, **options.except(:as_values, :reference_white, :target_white)
            )
          end
        end

        def is_a?(mod)
          mod == Transform || super
        end

        def pretty_print(pp)
          name_string = pp.text(name).to_s.gsub(name.length.to_s, '')

          pp.group(1, "#{name_string}[", ']') do
            rows = matrix.to_a

            return if rows.empty?

            widths = Array.new(matrix.column_count, 0)
            rows.each do |row|
              row.each_with_index do |val, j|
                val_str = val.nil? ? 'nil' : val.to_s
                widths[j] = [widths[j], val_str.length].max
              end
            end

            pp.breakable("\n")

            rows.each_with_index do |row, i|
              pp.text('  ')
              row.each_with_index do |val, j|
                pp.text(' ') if j.positive?
                val_str = val.nil? ? 'nil' : val.to_s
                pp.text(val_str.rjust(widths[j]))
              end

              pp.breakable("\n") if i < rows.size - 1
            end

            pp.breakable("\n")
          end
        end

        protected

        def transform(*rows)
          concurrent_instance_variable_set(:@matrix, Core::Matrix[*rows])
        end

        private

        def method_missing(method, ...)
          return super unless respond_to_missing?(method)

          matrix.public_send(method, ...)
        end

        def respond_to_missing?(method, include_private = false)
          matrix.respond_to?(method) || super
        end
      end
    end
  end
end
