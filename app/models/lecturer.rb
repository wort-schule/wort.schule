# frozen_string_literal: true

class Lecturer < User
  self.table_name = :users
  self.inheritance_column = :role
end
