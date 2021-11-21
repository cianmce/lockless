# frozen_string_literal: true

module Lockless
  # Handles lockless saves
  module Model
    extend ActiveSupport::Concern

    included do
      class_attribute :lockless_column
      self.lockless_column = :lockless_uuid

      before_save :set_lockless_uuid
    end

    # Saves record if it has not be modified in the time after it was loaded from the database.
    #
    # @return [Boolean] Similar to `.save`, true is returned if the model is updated
    # false is returned if record is outdated or invalid
    def lockless_save
      return false unless valid?
      old_lockless_uuid = lockless_uuid
      return save if new_record?

      run_callbacks(:save) do |variable|
        new_attrs = changed.collect { |prop| [prop.to_sym, self[prop]] }.to_h

        update_count = self.class.where(id: id, lockless_uuid: old_lockless_uuid).update_all(new_attrs)
        if update_count == 1
          changes_applied
          true
        else
          self.lockless_uuid = old_lockless_uuid
          false
        end
      end
    end

    # Saves record if it has not be modified in the time after it was loaded from the database.
    #
    # @return [Boolean] Similar to `.save!`, true is returned if the model is updated
    # false is returned if record is outdated
    #
    # @raise [ActiveRecord::RecordInvalid] if record is invalid
    def lockless_save!
      validate!
      lockless_save
    end

    private

    def set_lockless_uuid
      self.lockless_uuid = SecureRandom.uuid
    end
  end
end
