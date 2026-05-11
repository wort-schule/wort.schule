# frozen_string_literal: true

module BulkEdit::FieldStrategy
  class UnknownField < StandardError; end

  def self.for(field)
    case field
    when *BulkEdit::HABTM_FIELDS then Habtm.new(field)
    when *BulkEdit::BELONGS_TO_FIELDS then BelongsTo.new(field)
    when *BulkEdit::BOOLEAN_FIELDS then Boolean.new(field)
    else raise UnknownField, field.inspect
    end
  end
end
