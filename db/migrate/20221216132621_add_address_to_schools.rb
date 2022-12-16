class AddAddressToSchools < ActiveRecord::Migration[7.0]
  def change
    add_column :schools, :street, :string
    add_column :schools, :zip_code, :string
    add_column :schools, :city, :string
    add_column :schools, :country, :string
    add_column :schools, :homepage_url, :string
    add_column :schools, :email, :string
    add_column :schools, :phone_number, :string
    add_column :schools, :fax_number, :string
  end
end
