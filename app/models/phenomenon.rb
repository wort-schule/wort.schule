# frozen_string_literal: true

class Phenomenon < ApplicationRecord
  has_and_belongs_to_many :words
  validates_presence_of :name

  def self.values
    distinct.pluck(:name).sort
  end

  def self.collection
    distinct.order(:name).pluck(:id, :name)
  end
end
