class AddAccessToLearningGroupMemberships < ActiveRecord::Migration[7.0]
  def change
    add_column :learning_group_memberships, :access, :string
  end
end
