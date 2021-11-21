# frozen_string_literal: true

module Lockless
  module Relation
    def update_all(updates)
      if model.method_defined?(:lockless_column) && updates[model.lockless_column].blank?
        updates[model.lockless_column] = model.generate_uuid
      end

      super(updates)
    end
  end
end

ActiveRecord::Relation.prepend(Lockless::Relation)
