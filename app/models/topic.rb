# frozen_string_literal: true

class Topic < ApplicationRecord
  default_scope { order(:name) }

  has_and_belongs_to_many :words, counter_cache: :words_count

  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_fill: [100, 100], format: :png
    attachable.variant :open_graph, resize_to_fill: [1200, 630], format: :png
  end

  validates_presence_of :name

  def self.values
    distinct.pluck(:name).sort
  end

  def self.collection
    distinct.order(:name).pluck(:id, :name)
  end
end
