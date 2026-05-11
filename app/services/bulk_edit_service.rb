# frozen_string_literal: true

class BulkEditService
  class AlreadyUndone < StandardError; end

  class AlreadyReverted < StandardError; end

  attr_reader :user

  def initialize(user:)
    @user = user
  end

  def execute(word_ids:, field:, operation:, value:, search_query: nil, missing_field: nil)
    strategy = BulkEdit::FieldStrategy.for(field)
    unless strategy.operations.include?(operation)
      raise ArgumentError, "Operation #{operation.inspect} not allowed for #{field.inspect}"
    end

    applied = []

    ActiveRecord::Base.transaction do
      Word.where(id: word_ids).find_each do |word|
        word.with_lock do
          result = strategy.apply(word, value, operation)
          applied << {word_id: word.id, previous: result[:previous], applied: result[:applied]} if result
        end
      end

      # No-Op: keine echte Änderung an irgendeinem Wort → kein leerer Protokoll-Eintrag.
      next if applied.empty?

      bulk_edit = BulkEdit.create!(
        user: @user,
        field: field,
        operation: operation,
        intent_value: value,
        search_query: search_query,
        missing_field: missing_field,
        affected_count: applied.size
      )

      now = Time.current
      BulkEditChange.insert_all!(
        applied.map { |c|
          {
            bulk_edit_id: bulk_edit.id,
            word_id: c[:word_id],
            previous_value: c[:previous],
            applied_value: c[:applied],
            created_at: now,
            updated_at: now
          }
        }
      )

      @result = bulk_edit
    end

    @result
  end

  def undo(bulk_edit)
    raise AlreadyUndone if bulk_edit.undone?
    strategy = BulkEdit::FieldStrategy.for(bulk_edit.field)

    ActiveRecord::Base.transaction do
      bulk_edit.word_changes.pending.includes(:word).find_each do |change|
        revert_one(strategy, change)
      end
      bulk_edit.update!(undone_at: Time.current)
    end
  end

  def undo_change(change)
    raise AlreadyReverted if change.reverted?
    strategy = BulkEdit::FieldStrategy.for(change.bulk_edit.field)

    ActiveRecord::Base.transaction do
      revert_one(strategy, change)
      auto_complete_undo(change.bulk_edit)
    end
  end

  private

  # Sperrt das Change selbst → zwei parallele Undos serialisieren sich.
  # Innerhalb der Change-Sperre wird zusätzlich das Word gesperrt.
  def revert_one(strategy, change)
    change.with_lock do
      return if change.reverted?
      word = change.word
      if word.nil?
        Rails.logger.warn("BulkEditChange #{change.id} skipped — word #{change.word_id} not found")
      else
        word.with_lock { strategy.revert(word, change) }
      end
      change.update!(reverted_at: Time.current)
    end
  end

  def auto_complete_undo(bulk_edit)
    return if bulk_edit.undone?
    return if bulk_edit.word_changes.pending.exists?
    bulk_edit.update!(undone_at: Time.current)
  end
end
