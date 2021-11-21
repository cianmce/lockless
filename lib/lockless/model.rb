# frozen_string_literal: true

module Lockless
  # Handles lockless saves
  #
  # Options:
  #
  # - :lockless_column - The columns used to track the version of the record, defaults to `:lockless_uuid`.
  module Model
    extend ActiveSupport::Concern

    included do
      class_attribute :lockless_column
      self.lockless_column = :lockless_uuid

      before_save :set_lockless_uuid
    end

    def set_lockless_uuid
      self.lockless_uuid = SecureRandom.uuid
    end

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

    def lockless_save!
      validate!
      lockless_save
    end
  end
end
