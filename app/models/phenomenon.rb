class Phenomenon < ApplicationRecord
  has_and_belongs_to_many :words
  validates_presence_of :name

  def self.values
    distinct.pluck(:name).sort
  end
end
