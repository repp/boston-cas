class FixLeaseAndOwnerAttrTypes < ActiveRecord::Migration
  def change
    change_column :contacts, :owner_identifier, :string
    change_column :leases, :elite_lease_id, :string
  end
end
