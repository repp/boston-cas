module CasSeeds
  class Leases
    require 'csv'
    require 'json'

    def run!
      fails = 0
      csv = CSV.read('config/formatted_slc_leases.csv', headers: true, encoding: 'bom|utf-8')
      Rails.logger.info "Importing #{csv.length} Leases"
      csv.each do |row|
        c = Lease.where(elite_lease_id: row['elite_lease_id']).first_or_create
        lease_data = row.to_hash
        owner = Contact.where(owner_identifier: lease_data['owner_id'], is_building_owner: true).first
        Rails.logger.info owner.id.to_s
        if owner.present?
          lease_data['owner_id'] = owner.id
          c.assign_attributes row.to_hash.except('elite_lease_id')
          begin
            c.save!
          rescue
            Rails.logger.info lease_data
            fails += 1
          end
        end
      end
      Rails.logger.info 'Added Leases - ' + fails.to_s + ' failures'
    end
  end
end