class AddHitCounterToWords < ActiveRecord::Migration[7.0]
  def change
    add_column :words, :hit_counter, :bigint, default: 0, null: false
  end
end
