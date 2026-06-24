class Topic < ApplicationRecord
  include Collectable
  include HasStandardImage

  default_scope { order(:name) }

  has_and_belongs_to_many :words, counter_cache: :words_count

  # Topics present in the given Word relation (all of them when nothing is
  # filtered). Populates the search filter dropdown.
  scope :for_words, ->(words) {
    (words.count == Word.count) ? all : where(id: words.joins(:topics).pluck("topics.id"))
  }

  validates :name, presence: true
end
