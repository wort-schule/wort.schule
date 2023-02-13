class ChangeToUserRole < ActiveRecord::Migration[7.0]
  def up
    User.where.not(role: %w[Admin Teacher]).update_all(role: 'Guest')
    User.where(role: 'Teacher').update_all(role: 'Lecturer')
  end

  def down
    User.where(role: 'Lecturer').update_all(role: 'Teacher')
    User.where.not(role: %w[Admin Teacher]).update_all(role: 'Guest')
  end
end
