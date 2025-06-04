# frozen_string_literal: true

module Iro
  module Space
    module Behavior
      module Transform
        class << self
          private

          def included(base)
            super

            base.include InstanceMethods
          end
        end

        module InstanceMethods
          protected

          def after_transform
            self
          end

          def before_transform(_other_space_class, **)
            self
          end

          private

          def method_missing(method, ...)
            return super unless respond_to_missing?(method)

            other_identifier = method.to_s.sub(/^to_/, '').to_sym

            @mutex.synchronize do
              self.class.define_method(method) { |**options| transform_to(other_identifier, **options) }
            end

            public_send(method, ...)
          end

          def respond_to_missing?(method, include_private = false)
            if method.start_with?('to_')
              other_identifier = method.to_s.sub(/^to_/, '').to_sym
              !Space.transform.compose(identifier, other_identifier).nil?
            else
              super
            end
          end

          def transform_to(other_identifier, normalized: true, **options)
            space = Space.registry[other_identifier]
            raise ArgumentError, "unknown color space #{identifier}" unless space

            conversion_context = (context&.to_h || EMPTY_HASH).merge(space.context&.to_h || EMPTY_HASH)
            transform          = Space.transform.compose(identifier, other_identifier)
            raise NoTransformPathError, "#{self.class} does cannot be transformed to #{space}" unless transform

            Iro.logger.debug do
              "transforming #{self} to #{space} with " \
                "context: #{conversion_context}, " \
                "options: #{options.merge(normalized:)}"
            end

            to_transform = before_transform(space, **conversion_context)

            components = Iro.cache.fetch(:"#{identifier}_to_#{other_identifier}", to_transform, conversion_context) do
              transform.call(self, **conversion_context)
            end

            if options.fetch(:as_values, false)
              components
            else
              context_options = if space.const_defined?(:Context)
                                  options.slice(*space::Context.attributes.keys)
                                else
                                  EMPTY_HASH
                                end

              result = space.new(*components, normalized:, validate: false, **options.except(:as_values))
                            .with_context(**context_options)
              result.send(:after_transform)
            end
          end
        end
      end
    end
  end
end
