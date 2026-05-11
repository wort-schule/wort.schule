# frozen_string_literal: true

module BulkEditsHelper
  def bulk_edit_field_options
    [
      [Phenomenon.model_name.human(count: 2), "phenomenons"],
      [Strategy.model_name.human(count: 2), "strategies"],
      [Topic.model_name.human(count: 2), "topics"],
      [Word.human_attribute_name(:hierarchy), "hierarchy_id"],
      [Word.human_attribute_name(:prefix), "prefix_id"],
      [Word.human_attribute_name(:postfix), "postfix_id"],
      [Word.human_attribute_name(:prototype), "prototype"],
      [Word.human_attribute_name(:foreign), "foreign"],
      [Word.human_attribute_name(:compound), "compound"]
    ]
  end

  def display_bulk_edit_values(bulk_edit)
    case bulk_edit.field
    when "topics"
      Topic.where(id: bulk_edit.assigned_values).pluck(:name).join(", ")
    when "strategies"
      Strategy.where(id: bulk_edit.assigned_values).pluck(:name).join(", ")
    when "phenomenons"
      Phenomenon.where(id: bulk_edit.assigned_values).pluck(:name).join(", ")
    when "hierarchy_id"
      Hierarchy.find_by(id: bulk_edit.assigned_values.first)&.name
    when "prefix_id"
      Prefix.find_by(id: bulk_edit.assigned_values.first)&.name
    when "postfix_id"
      Postfix.find_by(id: bulk_edit.assigned_values.first)&.name
    when "prototype", "foreign", "compound"
      bulk_edit.assigned_values.first ? t("simple_form.yes") : t("simple_form.no")
    end
  end

  def operation_badge_class(operation)
    case operation
    when "add"
      "bg-green-100 text-green-800"
    when "remove"
      "bg-red-100 text-red-800"
    when "set"
      "bg-blue-100 text-blue-800"
    end
  end
end
