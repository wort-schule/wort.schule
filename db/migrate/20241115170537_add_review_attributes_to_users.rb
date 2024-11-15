class AddReviewAttributesToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :review_attributes, :string, array: true, null: false, default: []
  end
end
