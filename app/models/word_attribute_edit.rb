# frozen_string_literal: true

class WordAttributeEdit < ApplicationRecord
  belongs_to :word, polymorphic: true
  belongs_to :change_group

  def attribute_label
    word.class.human_attribute_name(attribute_name)
  end

  def current_value
    values = word.send(attribute_name)

    return values.pluck(:name).sort.join(", ") if values.is_a?(ActiveRecord::Relation)

    values
  end

  def proposed_value
    JSON.parse(value) if value.present?
  end
end
