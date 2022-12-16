class AddFederalStateToSchools < ActiveRecord::Migration[7.0]
  def change
    add_column :schools, :federal_state, :string
  end
end
