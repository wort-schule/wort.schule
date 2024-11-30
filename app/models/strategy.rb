class Strategy < ApplicationRecord
  has_and_belongs_to_many :words
  validates_presence_of :name

  has_one_attached :fresch_symbol

  def self.values
    distinct.pluck(:name).sort
  end
end
