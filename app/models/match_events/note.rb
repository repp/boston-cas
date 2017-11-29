module MatchEvents
  class Note < Base
    # Overall Match Notes are implemented as events
    validates :note, presence: true
    
    def name
      if admin_note
        'Administrative note added'
      else
        'Note added'
      end
    end
    
    def remove_note!
      destroy
    end

    def is_editable?
      true
    end

    def show_note?(current_contact)
      note.present? && (! admin_note || match.can_create_administrative_note?(current_contact))
    end
    
  end
end