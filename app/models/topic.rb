class Topic < ApplicationRecord
  include Collectable
  include HasStandardImage
  default_scope { order(:name) }

  has_and_belongs_to_many :words, counter_cache: :words_count

  validates_presence_of :name
end
