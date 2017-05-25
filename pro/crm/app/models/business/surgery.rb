module Business
  class Surgery
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :organization, class_name: "Business::Organization", index: true
    belongs_to :contact, class_name: "Business::Contact", index: true
    belongs_to :lead, class_name: "Business::Lead", index: true
    belongs_to :source, class_name: "Business::Source", index: true
    belongs_to :user, index: true


    field :physician_id, type: String
    field :cost, type: Integer
    field :date, type: DateTime
    field :completed, type: Boolean, default: false
    field :cancelled, type: Boolean, default: false
    field :procedure, type: String

    validates_presence_of :physician_id, :cost, :date, :procedure

    after_create :set_associations
    after_save :cancel_surgery

    def set_associations
      self.source = lead.source
      self.contact = lead.contact
      self.user = lead.user
      self.organization = lead.organization
      self.lead.consultation.booked = true
      self.lead.consultation.save
      self.save
    end

    def cancel_surgery
      if self.cancelled == true
        if self.lead.present?
          self.lead.update_attribute(:stage, "booked_consult")
          self.lead.save
        end
      end
    end

    def self.date_range(start_date, end_date)
      where(:date.gte => start_date, :date.lte => end_date)
    end

    def start_time
      self.date
    end

    def self.completed_surgeries
      where(completed: true)
    end

  end
end
