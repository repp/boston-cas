module MatchProgressUpdates
  class Ssp < Base
    
    def name
      'Stabilization Service Provider status update'
    end

    def responses
      [
        'Response 1',
        'Response 2',
      ]
    end

    def self.match_contact_scope
      :ssp_contacts
    end
  end
end