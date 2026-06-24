class Source < ApplicationRecord
  validates :name, presence: true
  has_and_belongs_to_many :words, counter_cache: :words_count

  # Sources present in the given Word relation (all of them when nothing is
  # filtered). Populates the search filter dropdown.
  scope :for_words, ->(words) {
    (words.count == Word.count) ? all : where(id: words.joins(:sources).pluck("sources.id"))
  }
end
