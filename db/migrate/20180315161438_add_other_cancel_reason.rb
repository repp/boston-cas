class AddOtherCancelReason < ActiveRecord::Migration
  def change
    add_column :match_decisions, :administrative_cancel_reason_other_explanation, :string
  end
end
