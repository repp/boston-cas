class AddCanViewLeasesToRoles < ActiveRecord::Migration

  def up
    unless column_exists?(:roles, :can_view_leases)
      add_column :roles, :can_view_leases, :boolean, default: false, null: false
      add_column :roles, :can_edit_leases, :boolean, default: false, null: false
      admin = Role.where(name: 'admin').first
      dnd = Role.where(name: 'dnd_staff').first
      admin.update(can_view_leases: true)
      admin.update(can_edit_leases: true)
      dnd.update(can_view_leases: true)
      dnd.update(can_edit_leases: true)
    end
  end

  def down
    remove_column :roles, :can_view_leases, :boolean, null: false, default: false
    remove_column :roles, :can_edit_leases, :boolean, null: false, default: false
  end

end
