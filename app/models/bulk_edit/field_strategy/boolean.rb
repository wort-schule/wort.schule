# frozen_string_literal: true

class BulkEdit::FieldStrategy::Boolean < BulkEdit::FieldStrategy::Base
  OPERATIONS = %w[set].freeze

  def operations = OPERATIONS

  def type_token = "boolean"

  def label = Word.human_attribute_name(@field)

  def normalize_input(raw)
    raw = raw.first if raw.is_a?(Array)
    return nil if raw.blank?
    {"value" => ActiveModel::Type::Boolean.new.cast(raw)}
  end

  def apply(word, value, _operation)
    new_v = value["value"]
    old_v = word.public_send(@field)
    return nil if old_v == new_v

    word.update!(@field => new_v)
    {previous: {"value" => old_v}, applied: {"value" => new_v}}
  end

  def revert(word, change)
    word.update!(@field => change.previous_value["value"])
  end

  def current_value(word) = word.public_send(@field)

  def display_current(word) = display_bool(word.public_send(@field))

  def display_value(value) = display_bool(value["value"])

  def missing_scope(scope)
    scope.where(@field => [nil, false])
  end

  private

  def display_bool(v)
    case v
    when true then I18n.t("simple_form.yes")
    when false then I18n.t("simple_form.no")
    else none_label
    end
  end
end
