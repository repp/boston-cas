class CreateLeases < ActiveRecord::Migration
  def change
    create_table :leases do |t|
      t.integer :elite_lease_id
      t.decimal :rent_total
      t.decimal :rent_program_paid
      t.references :owner, index: true, references: :contacts
      t.datetime :deleted_at
      t.datetime :lease_updated_at

      t.timestamps null: false
    end

    add_foreign_key :leases, :contacts, column: :owner_id
  end
end
