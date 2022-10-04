class Topic < ApplicationRecord
  default_scope { order(:name) }

  has_and_belongs_to_many :words

  validates_presence_of :name
end
