class AddUniqueIndices < ActiveRecord::Migration[7.0]
  def change
    add_index :learning_group_memberships, %i[learning_group_id student_id], unique: true, name: :index_learning_group_membership_unique
  end
end
