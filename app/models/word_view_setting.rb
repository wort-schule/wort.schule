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
  enumerize :word_type_wording, in: WordTypes.keys, default: WordTypes.keys.first
  enumerize :genus_wording, in: Genus.keys, default: Genus.keys.first
  enumerize :numerus_wording, in: Numerus.keys, default: Numerus.keys.first

  validates :name, presence: true
  validate :public_visibility_only_for_admins

  private

  def public_visibility_only_for_admins
    if visibility.to_s == "public" && owner.role != "Admin"
      errors.add(:visibility, :invalid)
    end
  end
end
