class Prefix < ApplicationRecord
  include Collectable
  extend Enumerize

  has_many :words
  validates :name, presence: true

  enumerize :prefix_type, in: %w[Verb adjective noun]
end
