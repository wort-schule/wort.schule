# frozen_string_literal: true

class Teacher < User
  self.table_name = :users
  self.inheritance_column = :role

  has_and_belongs_to_many :schools
end
