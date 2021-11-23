# frozen_string_literal: true

module Lockless
  module Relation

    # Appends updated attribute of a random UUID to each update command
    # when the model is a lockless model
    #
    # @param [String, Array, Hash] A string, array, or hash representing the SET part of an SQL statement.
    # Lockless will only append random UUID to updates if the param is a Hash
    #
    # @return [Boolean] Similar to `.save`, true is returned if the model is updated
    # false is returned if record is outdated or invalid
    def update_all(updates)
      if updates.is_a?(Hash)
        if model.method_defined?(:lockless_column) && updates[model.lockless_column].blank?
          updates[model.lockless_column] = model.generate_uuid
        end
      end

      super(updates)
    end
  end
end

ActiveRecord::Relation.prepend(Lockless::Relation)
