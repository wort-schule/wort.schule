class ChangeRoleToUppercaseFromUsers < ActiveRecord::Migration[7.0]
  def up
    User.find_each do |user|
      role = user.role&.titleize.presence || 'Guest'
      user.update_attribute(:role, role)
    end

    change_column :users, :role, :string, default: 'Guest'
  end

  def down
    change_column :users, :role, :string, default: 'none'

    User.find_each do |user|
      role = user.role&.downcase.presence || 'none'
      user.update_attribute(:role, role)
    end
  end
end
