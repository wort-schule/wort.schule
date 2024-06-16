# frozen_string_literal: true

class WordViewSetting < ApplicationRecord
  extend Enumerize

  belongs_to :owner, class_name: "User"

  belongs_to :theme_noun, class_name: "Theme", optional: true
  belongs_to :theme_verb, class_name: "Theme", optional: true
  belongs_to :theme_adjective, class_name: "Theme", optional: true
  belongs_to :theme_function_word, class_name: "Theme", optional: true

  has_many :learning_groups

  enumerize :visibility, in: %i[private public], default: :private

  validates :name, presence: true
  validate :public_visibility_only_for_admins

  private

  def public_visibility_only_for_admins
    if visibility.to_s == "public" && owner.role != "Admin"
      errors.add(:visibility, :invalid)
    end
  end
end
