class Hierarchy < ApplicationRecord
  default_scope { order(:name) }

  belongs_to :parent, class_name: "Hierarchy", optional: true, foreign_key: "top_hierarchy_id"
  has_many :children, class_name: "Hierarchy", foreign_key: "top_hierarchy_id"
  has_many :words

  validates_presence_of :name
end
