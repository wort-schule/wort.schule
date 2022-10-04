class AddIdToTeachingAssignments < ActiveRecord::Migration[7.0]
  def change
    rename_table :schools_teachers, :teaching_assignments
    add_column :teaching_assignments, :id, :primary_key
  end
end
