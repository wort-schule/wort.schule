class Postfix < ApplicationRecord
  has_many :words
  validates_presence_of :name

  def self.values
    distinct.pluck(:name)
  end
end
