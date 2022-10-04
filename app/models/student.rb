# frozen_string_literal: true

class Student < User
  self.table_name = :users
  self.inheritance_column = :role

  has_many :learning_group_memberships, dependent: :destroy
  has_many :learning_groups, through: :learning_group_memberships
end
