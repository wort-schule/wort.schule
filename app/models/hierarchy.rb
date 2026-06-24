class Hierarchy < ApplicationRecord
  include Collectable
  include HasStandardImage

  default_scope { order(:name) }

  belongs_to :parent, class_name: "Hierarchy", optional: true, foreign_key: "top_hierarchy_id"
  has_many :children, class_name: "Hierarchy", foreign_key: "top_hierarchy_id", dependent: :nullify
  has_many :words, dependent: :nullify, counter_cache: :words_count

  # Hierarchies present in the given Word relation (all of them when nothing is
  # filtered). Populates the search filter dropdown.
  scope :for_words, ->(words) {
    (words.count == Word.count) ? all : where(id: words.pluck(:hierarchy_id))
  }

  validates :name, presence: true
end
