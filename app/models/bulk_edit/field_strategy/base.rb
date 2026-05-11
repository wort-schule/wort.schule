# frozen_string_literal: true

class BulkEdit::FieldStrategy::Base
  attr_reader :field

  def initialize(field)
    @field = field
  end

  def label = raise NotImplementedError

  def operations = raise NotImplementedError

  def type_token = raise NotImplementedError

  def normalize_input(_raw) = raise NotImplementedError

  def apply(_word, _value, _operation) = raise NotImplementedError

  def revert(_word, _change) = raise NotImplementedError

  def current_value(_word) = raise NotImplementedError

  def display_current(_word) = raise NotImplementedError

  def display_value(_value) = raise NotImplementedError

  def missing_scope(_scope) = raise NotImplementedError

  def none_label = I18n.t("bulk_edits.values.none")
end
