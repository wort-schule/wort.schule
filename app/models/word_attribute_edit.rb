# frozen_string_literal: true

class WordAttributeEdit < ApplicationRecord
  belongs_to :word, polymorphic: true
  belongs_to :change_group

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
end
