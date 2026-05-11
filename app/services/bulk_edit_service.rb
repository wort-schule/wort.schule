# frozen_string_literal: true

class BulkEditService
  attr_reader :user

  def initialize(user:)
    @user = user
  end

  def execute(word_ids:, field:, operation:, values:, search_query: nil)
    raise ArgumentError, "Unknown field: #{field}" unless BulkEdit::ALL_FIELDS.include?(field)

    previous_values = {}

    ActiveRecord::Base.transaction do
      words = Word.where(id: word_ids)

      if BulkEdit::HABTM_FIELDS.include?(field)
        model_class = field.classify.constantize

        words.find_each do |word|
          association = word.public_send(field)
          existing_ids = association.pluck(:id)

          if operation == "add"
            new_ids = values.map(&:to_i) - existing_ids
            if new_ids.any?
              association << model_class.where(id: new_ids)
              previous_values[word.id.to_s] = new_ids
            end
          elsif operation == "remove"
            removable_ids = values.map(&:to_i) & existing_ids
            if removable_ids.any?
              association.delete(model_class.where(id: removable_ids))
              previous_values[word.id.to_s] = removable_ids
            end
          end
        end
      elsif BulkEdit::BELONGS_TO_FIELDS.include?(field)
        value = values.first
        value = value.to_i if value.present? && value != ""
        value = nil if value == "" || value == 0

        words.find_each do |word|
          old_value = word.public_send(field)
          next if old_value == value

          previous_values[word.id.to_s] = old_value
          word.update!(field => value)
        end

        operation = "set"
      elsif BulkEdit::BOOLEAN_FIELDS.include?(field)
        value = ActiveModel::Type::Boolean.new.cast(values.first)

        words.find_each do |word|
          old_value = word.public_send(field)
          next if old_value == value

          previous_values[word.id.to_s] = old_value
          word.update!(field => value)
        end

        operation = "set"
      end

      BulkEdit.create!(
        user: user,
        operation: operation,
        field: field,
        word_ids: words.pluck(:id),
        assigned_values: values,
        previous_values: previous_values,
        search_query: search_query
      )
    end
  end

  def undo(bulk_edit)
    raise "Already undone" if bulk_edit.undone?

    retry_on_cache_expired do
      if BulkEdit::HABTM_FIELDS.include?(bulk_edit.field)
        model_class = bulk_edit.field.classify.constantize

        bulk_edit.previous_values.each do |word_id, delta_ids|
          word = Word.find_by(id: word_id)
          next unless word

          association = word.public_send(bulk_edit.field)

          if bulk_edit.operation == "add"
            association.delete(model_class.where(id: delta_ids))
          elsif bulk_edit.operation == "remove"
            existing_ids = association.pluck(:id)
            new_ids = delta_ids.map(&:to_i) - existing_ids
            association << model_class.where(id: new_ids) if new_ids.any?
          end
        end
      elsif BulkEdit::BELONGS_TO_FIELDS.include?(bulk_edit.field) ||
          BulkEdit::BOOLEAN_FIELDS.include?(bulk_edit.field)
        bulk_edit.previous_values.each do |word_id, old_value|
          word = Word.find_by(id: word_id)
          next unless word

          word.update!(bulk_edit.field => old_value)
        end
      end

      bulk_edit.update!(undone: true, undone_at: Time.current)
    end
  end

  private

  def retry_on_cache_expired(&)
    ActiveRecord::Base.transaction(&)
  rescue ActiveRecord::PreparedStatementCacheExpired
    ActiveRecord::Base.transaction(&)
  end
end
