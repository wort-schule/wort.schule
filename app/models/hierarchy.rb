class Hierarchy < ApplicationRecord
  default_scope { order(:name) }

  belongs_to :parent, class_name: "Hierarchy", optional: true, foreign_key: "top_hierarchy_id"
  has_many :children, class_name: "Hierarchy", foreign_key: "top_hierarchy_id"
  has_many :words

  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_fill: [100, 100], format: :png
    attachable.variant :open_graph, resize_to_fill: [1200, 630], format: :png
  end

  validates_presence_of :name
end
