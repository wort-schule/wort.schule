# frozen_string_literal: true

class BulkEdit::FieldStrategy::BelongsTo < BulkEdit::FieldStrategy::Base
  OPERATIONS = %w[set].freeze

  def operations = OPERATIONS

  def type_token = "belongs_to"

  def label = Word.human_attribute_name(@field.delete_suffix("_id"))

  def normalize_input(raw)
    id = Array(raw).first.presence
    {"id" => id&.to_i}
  end

  def apply(word, value, _operation)
    new_id = value["id"]
    old_id = word.public_send(@field)
    return nil if old_id == new_id

    word.update!(@field => new_id)
    {previous: {"id" => old_id}, applied: {"id" => new_id}}
  end

  def revert(word, change)
    word.update!(@field => change.previous_value["id"])
  end

  def current_value(word) = word.public_send(@field)

  def display_current(word)
    associated = word.public_send(@field.delete_suffix("_id"))
    associated&.name || none_label
  end

  def display_value(value)
    ref_model.find_by(id: value["id"])&.name || none_label
  end

  def missing_scope(scope)
    scope.where(@field => nil)
  end

  private

  def ref_model = @field.delete_suffix("_id").classify.constantize
end
