class AddRoleToLearningGroupMemberships < ActiveRecord::Migration[7.0]
  def change
    add_column :learning_group_memberships, :role, :string, default: 'member'
  end
end
