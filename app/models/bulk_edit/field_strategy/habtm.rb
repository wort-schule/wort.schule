# frozen_string_literal: true

class BulkEdit::FieldStrategy::Habtm < BulkEdit::FieldStrategy::Base
  OPERATIONS = %w[add remove].freeze

  def operations = OPERATIONS

  def type_token = "habtm"

  def label = model.model_name.human(count: 2)

  def normalize_input(raw)
    ids = Array(raw).flat_map { |v| v.is_a?(String) ? v.split(",") : v }
      .map(&:to_i).reject(&:zero?).uniq
    return nil if ids.empty?
    {"ids" => ids}
  end

  def apply(word, value, operation)
    requested = Array(value["ids"])
    existing = current_value(word)

    case operation
    when "add"
      delta = requested - existing
      return nil if delta.empty?
      model.where(id: delta).each { |m| word.public_send(@field) << m }
      {previous: {"ids" => []}, applied: {"ids" => delta}}
    when "remove"
      delta = requested & existing
      return nil if delta.empty?
      word.public_send(@field).delete(model.where(id: delta))
      {previous: {"ids" => delta}, applied: {"ids" => []}}
    end
  end

  def revert(word, change)
    added = Array(change.applied_value["ids"])
    removed = Array(change.previous_value["ids"])

    word.public_send(@field).delete(model.where(id: added)) if added.any?

    if removed.any?
      currently = word.public_send(@field).map(&:id)
      to_readd = removed - currently
      model.where(id: to_readd).each { |m| word.public_send(@field) << m } if to_readd.any?
    end
  end

  def current_value(word) = word.public_send(@field).map(&:id)

  def display_current(word)
    names = word.public_send(@field).map(&:name)
    names.empty? ? none_label : names.join(", ")
  end

  def display_value(value)
    ids = Array(value["ids"])
    return none_label if ids.empty?
    model.where(id: ids).pluck(:name).join(", ")
  end

  def missing_scope(scope)
    scope.where.missing(@field.to_sym)
  end

  private

  def model = @field.classify.constantize
end
