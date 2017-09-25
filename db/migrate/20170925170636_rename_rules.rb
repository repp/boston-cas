class RenameRules < ActiveRecord::Migration
  def up
    rule = Rules::OneEightyDaysHomeless&.first
    rule.update(name: '180 homeless days') if rule.present?
    rule = Rules::OneYearHomeless&.first
    rule.update(name: '365 homeless days') if rule.present?
  end
end
