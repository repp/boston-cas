class AddHousingAuthorityEligibile < ActiveRecord::Migration
  def change
    [:clients, :project_clients].each do |table|
      add_column table, :ha_eligible, :boolean, default: false, null: false
    end
  end
end
