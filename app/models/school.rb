class School < ApplicationRecord
  has_many :teaching_assignments
  has_many :teachers, through: :teaching_assignments
  has_many :learning_groups

  validates_presence_of :name

  def to_s
    name
  end
end
