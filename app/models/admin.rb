# frozen_string_literal: true

class Admin < User
  self.table_name = :users
  self.inheritance_column = :role
end
