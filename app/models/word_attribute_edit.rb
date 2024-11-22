# frozen_string_literal: true

class WordAttributeEdit < ApplicationRecord
  belongs_to :word, polymorphic: true
  belongs_to :change_group

  def attribute_label
    word.class.human_attribute_name(attribute_name)
  end

  def current_value
    word.send(attribute_name)
  end

  def proposed_value
    value
  end
end
