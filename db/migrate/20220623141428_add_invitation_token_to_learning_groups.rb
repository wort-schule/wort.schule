class AddInvitationTokenToLearningGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :learning_groups, :invitation_token, :string
    add_index :learning_groups, :invitation_token, unique: true

    add_column :learning_groups, :invitable, :boolean, default: false, null: false
  end
end
