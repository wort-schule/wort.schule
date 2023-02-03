class RemoveSchools < ActiveRecord::Migration[7.0]
  def up
    remove_column :learning_groups, :school_id

    drop_table :teaching_assignments
    drop_table :schools

    remove_foreign_key :learning_groups, column: :teacher_id
    rename_column :learning_groups, :teacher_id, :user_id

    remove_foreign_key :learning_group_memberships, column: :student_id
    rename_column :learning_group_memberships, :student_id, :user_id
  end

  def down
    create_table "schools", force: :cascade do |t|
      t.string "name"
      t.string "street"
      t.string "zip_code"
      t.string "city"
      t.string "country"
      t.string "homepage_url"
      t.string "email"
      t.string "phone_number"
      t.string "fax_number"
      t.string "federal_state"
      t.timestamps
    end

    create_table "teaching_assignments", force: :cascade do |t|
      t.bigint "school_id", null: false
      t.bigint "teacher_id", null: false
      t.index ["school_id", "teacher_id"], name: "index_teaching_assignments_on_school_id_and_teacher_id", unique: true
    end

    add_reference :learning_groups, :school, null: true, foreign_key: true
    rename_column :learning_groups, :user_id, :teacher_id
    rename_column :learning_group_memberships, :user_id, :student_id
  end
end
