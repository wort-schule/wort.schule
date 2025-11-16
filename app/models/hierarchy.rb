class Hierarchy < ApplicationRecord
  include Collectable
  include HasStandardImage
  default_scope { order(:name) }

  belongs_to :parent, class_name: "Hierarchy", optional: true, foreign_key: "top_hierarchy_id"
  has_many :children, class_name: "Hierarchy", foreign_key: "top_hierarchy_id", dependent: :nullify
  has_many :words, dependent: :nullify, counter_cache: :words_count

  validates :name, presence: true
end
