module Business
  class Consultation
  include Mongoid::Document
  include Mongoid::Timestamps

    belongs_to :organization, class_name: "Business::Organization", index: true
    belongs_to :contact, class_name: "Business::Contact", index: true
    belongs_to :lead, class_name: "Business::Lead", index: true
    belongs_to :user, index: true
    belongs_to :source, class_name: "Business::Source", index:true

    field :physician_id, type: String
    field :date, type: DateTime
    field :cancelled, type: Boolean, default: false
    field :no_show, type: Boolean, default: false
    field :cost, type: Integer
    field :booked, type: Boolean, default: false

    validates_presence_of :physician_id, :date, :cost

    after_create :set_associations
    after_save :cancel_consult

    def set_associations
      self.source = lead.source
      self.contact = lead.contact
      self.user = lead.user
      self.organization = lead.organization
      self.save
    end

    def cancel_consult
      if self.cancelled == true || self.no_show == true
        self.lead.update_attribute(:stage, "booked_consult")
        self.lead.save
      end
    end

    def self.date_range(start_date, end_date)
      where(:date.gte => start_date, :date.lte => end_date)
    end

    def start_time
      self.date
    end

  end
end
