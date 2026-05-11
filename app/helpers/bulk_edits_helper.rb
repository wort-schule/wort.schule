# frozen_string_literal: true

module BulkEditsHelper
  # Liefert die Feld-Optionen für das Field-Select gruppiert nach Feldtyp (HABTM/belongs_to/boolean).
  def bulk_edit_field_groups
    [
      [t("bulk_edits.field_groups.habtm"), BulkEdit::HABTM_FIELDS.map { |f| [BulkEdit::FieldStrategy.for(f).label, f, {"data-type" => "habtm"}] }],
      [t("bulk_edits.field_groups.belongs_to"), BulkEdit::BELONGS_TO_FIELDS.map { |f| [BulkEdit::FieldStrategy.for(f).label, f, {"data-type" => "belongs_to"}] }],
      [t("bulk_edits.field_groups.boolean"), BulkEdit::BOOLEAN_FIELDS.map { |f| [BulkEdit::FieldStrategy.for(f).label, f, {"data-type" => "boolean"}] }]
    ]
  end

  # Liefert die Hash der data-* Attribute, die in <tr> für ein Wort gerendert werden.
  # Jedes Feld bekommt zwei Attribute: data-current-<field> (typisierter Rohwert für Vergleiche)
  # und data-display-<field> (lokalisierter Anzeige-Text für die adaptive Spalte).
  def word_row_data(word)
    data = {word_id: word.id}
    BulkEdit::ALL_FIELDS.each do |field|
      strategy = BulkEdit::FieldStrategy.for(field)
      data["current_#{field}"] = strategy.current_value(word).to_json
      data["display_#{field}"] = strategy.display_current(word)
    end
    data
  end

  def operation_badge_class(operation)
    case operation
    when "add" then "bg-green-100 text-green-800"
    when "remove" then "bg-red-100 text-red-800"
    when "set" then "bg-blue-100 text-blue-800"
    end
  end
end
