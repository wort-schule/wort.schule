# frozen_string_literal: true

class List < ApplicationRecord
  extend Enumerize

  belongs_to :user
  has_and_belongs_to_many :words
  has_many :learning_pleas
  has_many :learning_groups, through: :learning_pleas

  enumerize :visibility, in: %i[private public], default: :private

  default_scope { where(flashcard_section: nil) }
  scope :of_user, ->(user) { where(user:) }

  validates :name, presence: true, if: ->(list) { list.flashcard_section.blank? }

  def to_s
    if flashcard_section.present?
      I18n.t(flashcard_section, scope: "activerecord.attributes.list.flashcard_sections")
    else
      name
    end
  end
end
