module CasSeeds
  class BuildingOwners
    require 'csv'
    require 'json'

    def run!
      csv = CSV.read('config/formatted_slc_owners.csv', headers: true, encoding: 'bom|utf-8')
      Rails.logger.info "Importing #{csv.length} Owners"
      csv.each do |row|
        c = Contact.where(owner_identifier: row['owner_identifier']).first_or_create
        c.assign_attributes row.to_hash.except('owner_identifier')
        c.save!
      end
      Rails.logger.info 'Added Building Owners'
    end
  end
end