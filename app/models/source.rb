class Source < ApplicationRecord
  validates :name, presence: true
  has_and_belongs_to_many :words, counter_cache: :words_count
end
