# frozen_string_literal: true

class Postfix < ApplicationRecord
  has_many :words
  validates_presence_of :name

  def self.values
    distinct.pluck(:name)
  end

  def self.collection
    distinct.order(:name).pluck(:id, :name)
  end
end
