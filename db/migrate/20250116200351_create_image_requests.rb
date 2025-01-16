class CreateImageRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :image_requests do |t|
      t.references :word, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :image_requests, [:word_id, :user_id], unique: true
  end
end
