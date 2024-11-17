# frozen_string_literal: true

class WordAttributeEdit < ApplicationRecord
  extend Enumerize
  include Reviewable

  belongs_to :word, polymorphic: true

  has_many :reviews, dependent: :destroy, inverse_of: :reviewable

  enumerize :state, in: %i[waiting_for_review edited confirmed invalid], default: :waiting_for_review

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
