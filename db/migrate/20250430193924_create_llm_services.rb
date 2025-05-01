class CreateLlmServices < ActiveRecord::Migration[7.2]
  def change
    create_table :llm_services do |t|
      t.string :name, null: false
      t.string :service_klass, null: false
      t.string :endpoint
      t.string :api_key
      t.string :model, null: false
      t.boolean :active, null: false, default: false

      t.timestamps
    end
  end
end
