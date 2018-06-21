class AddUtilityAllownaceToLeases < ActiveRecord::Migration
  def change
    add_column :leases, :utility_allowance, :decimal
  end
end
