class RemovePartOfAFamily < ActiveRecord::Migration
  def change
    remove_column :project_clients, :part_of_a_family, :boolean, default: false
    remove_column :clients, :part_of_a_family, :boolean, default: false
  end
end
