class Prefix < ApplicationRecord
  extend Enumerize

  has_many :words
  validates_presence_of :name

  enumerize :prefix_type, in: %w[Verb adjective noun]

  def self.values
    distinct.pluck(:name)
  end

  def self.collection
    distinct.order(:name).pluck(:id, :name)
  end
end
