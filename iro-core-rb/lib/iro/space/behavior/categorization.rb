# frozen_string_literal: true

module Iro
  module Space
    module Behavior
      module Categorization
        extend Support::Concurrent::InstanceVariable

        class << self
          def registry
            concurrent_instance_variable_fetch(:registry, Registry.new)
          end

          private

          def included(base)
            super

            base.extend  Support::Concurrent::InstanceVariable
            base.extend  ClassMethods
            base.include InstanceMethods
          end
        end

        class Registry < Support::Concurrent::Registry
          def register(category)
            category = category.to_sym
            return find(category) if exist?(category)

            Categorization::InstanceMethods.define_method(:"#{category}?") do
              self.class.categories.include?(category)
            end

            super(category, category)
          end
        end

        module ClassMethods
          def categories
            concurrent_instance_variable_fetch(:categories, EMPTY_ARRAY)
          end

          protected

          def categorized_as(*categories)
            categories.each { |category| Categorization.registry.register(category) }

            new_categories = categories.dup.concat(categories).uniq.sort.freeze
            concurrent_instance_variable_set(:categories, new_categories)
          end
        end

        module InstanceMethods
        end
      end
    end
  end
end
