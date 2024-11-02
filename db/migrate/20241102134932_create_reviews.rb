class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews do |t|
      t.references :reviewable, null: false, polymorphic: true
      t.references :reviewer, null: false, foreign_key: {to_table: :users}
      t.string :state, null: false

      t.timestamps
    end
  end
end
