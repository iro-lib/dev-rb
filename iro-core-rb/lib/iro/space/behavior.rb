# frozen_string_literal: true

module Iro
  module Space
    module Behavior
      class << self
        private

        def included(base)
          super

          base.extend  Support::Concurrent::InstanceVariable
          base.include Model::Behavior
          base.include Behavior::Abstract
          base.include Behavior::Categorization
          base.include Behavior::Coercion
          base.include Behavior::Comparison
          base.include Behavior::Context
          base.include Behavior::Identification
          base.include Behavior::Introspection
          base.include Behavior::Opacity
          base.include Behavior::PrimitiveConversion
          base.include Behavior::Transform
          base.include Support::Concurrent::InstanceVariable
        end
      end

      def initialize(*, **)
        raise AbstractSpaceError, "#{self.class} is abstract and cannot be instantiated" if self.class.abstract_space?

        @mutex = Mutex.new
        initialize_components!(*, **)
        initialize_opacity!(**)
        initialize_context!(**)
      end
    end
  end
end
