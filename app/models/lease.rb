class Lease < ActiveRecord::Base
  belongs_to :owner, class_name: "Contact"

  validates_presence_of :owner, :elite_lease_id, :rent_total, :rent_program_paid
  
  acts_as_paranoid
  has_paper_trail

  def rent_tenant_paid
     rent_total - rent_program_paid
  end

  def self.text_search(text)
    return none unless text.present?
    query = "%#{text}%"
    where(elite_lease_id: text)
  end
end
