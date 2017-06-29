module MatchDecisions
  class Base < ActiveRecord::Base
    # MatchDecision objects represent individual decision points
    # in the flow map for a given match.  e.g. DND initial approval,
    # or shelter agency approval

    # Decisions provide callback functionality for taking action based on
    # the current status.  See #run_status_callback

    # Subclasses should define valid statuses in #statuses and
    # corresponding callbacks in a StatusCallbacks inner class

    self.table_name = 'match_decisions'

    has_paper_trail
    acts_as_paranoid
    
    belongs_to :match, class_name: 'ClientOpportunityMatch', inverse_of: :decisions
    belongs_to :contact
    
    # these need to be present on the base class for preloading
    # subclasses should include MatchDecisions::AcceptsDeclineReason
    # and/or MatchDecisions::AcceptsNotWorkingWithClientReason if they intend to use these
    belongs_to :decline_reason, class_name: 'MatchDecisionReasons::Base'
    belongs_to :not_working_with_client_reason, class_name: 'MatchDecisionReasons::Base'
    belongs_to :administrative_cancel_reason, class_name: 'MatchDecisionReasons::Base'

    # We collect notes on our forms, and pass them on to events where they are stored
    attr_accessor :note
    # We provide an option to park clients on the DND initial review
    attr_accessor :prevent_matching_until
    # We provide an option to expire the shelter agency initial review
    attr_accessor :shelter_expiration

    scope :pending, -> { where(status: :pending) }
    
    has_many :decision_action_events,
      class_name: MatchEvents::DecisionAction.name,
      foreign_key: :decision_id

    has_many :status_updates,
      class_name: MatchProgressUpdates::Base.name,
      foreign_key: :decision_id

    validate :ensure_status_allowed, if: :status
    
    ####################
    # Attributes
    ####################
    
    alias_attribute :timestamp, :updated_at

    def label
      # default behavior.  subclasses will probably want to override this
      decision_type.humanize.titleize
    end

    def contact_name
      contact && contact.full_name
    end
    alias_method :actor_name, :contact_name

    def editable?
      # can notification responses update this decision?
      false
    end
    
    def to_param
      decision_type
    end
    
    def notifications fetch_strategy: :single_decision
      match.send("#{decision_type}_notifications")
    end
    
    def actor_type
      raise 'Abstract method'
    end

    def contact_actor_type
      raise 'Abstract method'
    end
    
    def step_name
      raise 'Not implemented'
    end
    
    ######################
    # Decision Lifecycle
    ######################  
    
    # This method is meant to be called when a decision becomes active
    # do things like set the initial "pending" status and
    # send notifications
    def initialize_decison!
      # no-op override in subclass
    end
    
    def initialized?
      status.present?
    end
    
    def editable?
      # can this decision be updated by a notification response?
      # override this default behavior in subclasses
      initialized? && match_open?
    end
    
    def match_open?
      !match.closed?
    end
    
    # Sometimes the contacts change during a match and notifications should be re-issued
    # to everyone including the new contact (This runs the notification part of StatusCallbacks#accepted on 
    # on the prior step)
    def recreate_notifications_for_this_step
      notifications_for_this_step.each do |n|
        n.create_for_match! match
      end
    end

    def notifications_for_this_step
      # override in subclass, return an array of notifications appropriate to resend for the current step
    end

    ######################
    # Status Handling
    ######################

    # override in subclass with a hash of {value: 'Label'}
    def statuses
      {}
    end
    
    # Overridden for decisions that can be overridden by DND and indicate
    # the status visually
    def status_label
      statuses[status && status.to_sym]
    end
    
    def run_status_callback! **dependencies
      status_callbacks.new(self, dependencies).public_send status
    end

    # inherit in subclasses and add methods for each entry in #statuses
    class StatusCallbacks      
      attr_reader :decision, :dependencies
      def initialize decision, options
        @decision = decision
        @dependencies = dependencies
      end
      delegate :match, to: :decision
    end
    private_constant :StatusCallbacks
    
    
    def record_action_event! contact:
      decision_action_events.create! match: match, contact: contact, action: status, note: note
    end

    # override in subclass
    def notify_contact_of_action_taken_on_behalf_of contact:

    end

    def self.model_name
      @_model_name ||= ActiveModel::Name.new(self, nil, "decision")
    end
    
    def to_partial_path
      "match_decisions/#{decision_type}"
    end
    
    def permitted_params
      [:status, :note, :prevent_matching_until]
    end

    def whitelist_params_for_update params
      result = params.require(:decision).permit(permitted_params)
      # also allow one cancel reason
      reason_id_array = Array.wrap params.require(:decision)[:administrative_cancel_reason_id]
      cancel_reason_id = reason_id_array.select(&:present?).first
      result.merge! administrative_cancel_reason_id: cancel_reason_id
      result
    end
    
    # override in subclass
    def accessible_by? contact
      false
    end
    
    def self.available_sub_types_for_search
      [
        'MatchDecisions::MatchRecommendationDndStaff',
        'MatchDecisions::MatchRecommendationShelterAgency',
        'MatchDecisions::ConfirmShelterAgencyDeclineDndStaff',
        'MatchDecisions::ScheduleCriminalHearingHousingSubsidyAdmin',
        'MatchDecisions::ApproveMatchHousingSubsidyAdmin',
        'MatchDecisions::ConfirmHousingSubsidyAdminDeclineDndStaff',
        'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator',
        # 'MatchDecisions::RecordClientHousedDateShelterAgency',
        'MatchDecisions::ConfirmMatchSuccessDndStaff',
      ]
    end

    def self.filter_options
      self.available_sub_types_for_search + ['Stalled Matches - with response', 'Stalled Matches - no response']
    end

    def canceled_status_label
      if administrative_cancel_reason.present?
        "Match canceled administratively: #{administrative_cancel_reason.name}"
      else
        'Match canceled administratively'
      end
    end

    private
    
      def decision_type
        self.class.to_s.demodulize.underscore
      end
    
      def status_callbacks
        self.class.const_get :StatusCallbacks
      end
      
      def ensure_status_allowed
        if statuses.with_indifferent_access[status].blank?
          errors.add :status, 'is not allowed'
        end
      end
      
      def notification_class
        "Notifications::#{self.class.to_s.demodulize}".constantize
      end
      
      def saved_status
        changed_attributes[:status] || status
      end
    
  end
  
end

