class CreateJoinTableListsWords < ActiveRecord::Migration[7.0]
  def change
    create_join_table :lists, :words do |t|
      # t.index [:list_id, :word_id]
      # t.index [:word_id, :list_id]
    end
  end
end
