# frozen_string_literal: true

class WordAttributeEdit < ApplicationRecord
  belongs_to :word, polymorphic: true
  belongs_to :change_group

  before_validation :normalize_attribute_name

  def attribute_label
    word.class.human_attribute_name(attribute_name)
  end

  def current_value
    values = word.send(attribute_name)

    if values.is_a?(ActiveRecord::Relation)
      return case attribute_name
             when "compound_entities"
               values.map { |compound_entity| compound_entity.part.name }.sort.join(", ")
             else
               values.pluck(:name).sort.join(", ")
             end
    end

    values
  end

  def proposed_value
    JSON.parse(value) if value.present?
  end

  private

  # Normalize attribute_name to remove any type prefix (e.g., "noun.case_1_plural" => "case_1_plural")
  # This ensures consistency with the reviewable scope which uses review_attributes_without_types
  def normalize_attribute_name
    return if attribute_name.blank?

    # Split on the first dot and take the last part
    # e.g., "noun.case_1_plural" => ["noun", "case_1_plural"] => "case_1_plural"
    # e.g., "case_1_plural" => ["case_1_plural"] => "case_1_plural"
    parts = attribute_name.split(".", 2)
    self.attribute_name = parts.last if parts.size > 1
  end
end
