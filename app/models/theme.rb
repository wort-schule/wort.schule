class Theme < ApplicationRecord
  extend Enumerize

  WORD_TYPES = %i[noun verb adjective function_word]

  belongs_to :user

  enumerize :visibility, in: %i[private public], default: :private
  enumerize :word_type, in: WORD_TYPES, default: :noun, scope: true

  validates :name, presence: true, uniqueness: true
  validates :template, presence: true
  validates :visibility, presence: true
  validates :word_type, presence: true

  def self.default_template(word_type:)
    File.read(Rails.root.join("app/views/themes/default_#{word_type}.liquid"))
  end
end
