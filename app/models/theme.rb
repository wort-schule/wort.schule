class Theme < ApplicationRecord
  extend Enumerize

  belongs_to :user

  enumerize :visibility, in: %i[private public], default: :private
  enumerize :word_type, in: %i[noun verb adjective], default: :noun, scope: true

  validates :name, presence: true, uniqueness: true
  validates :template, presence: true
  validates :visibility, presence: true
  validates :word_type, presence: true
end
