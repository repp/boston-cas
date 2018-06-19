class AddOwnerFieldsToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :is_building_owner, :boolean, default: false
    add_column :contacts, :business_name, :string
    add_column :contacts, :owner_identifier, :integer
    add_column :contacts, :address, :string
    add_column :contacts, :city, :string
    add_column :contacts, :state, :string
    add_column :contacts, :zip_code, :string

    add_index :contacts, :owner_identifier, unique: true
  end
end
