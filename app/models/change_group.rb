# frozen_string_literal: true

class ChangeGroup < ApplicationRecord
  extend Enumerize
  include Reviewable

  enumerize :state, in: %i[waiting_for_review edited confirmed invalid], default: :waiting_for_review

  has_many :word_attribute_edits, dependent: :destroy

  accepts_nested_attributes_for :word_attribute_edits
end
