module Business
  class Lead
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :organization, class_name: "Business::Organization", index: true
    belongs_to :contact, class_name: "Business::Contact", index: true
    belongs_to :user, index: true
    belongs_to :source, :class_name => 'Business::Source', index: true
    has_many :notes, as: :subject, dependent: :destroy, class_name: "Business::Note"
    has_many :tasks, as: :subject, dependent: :destroy, class_name: "Business::Task"
    has_many :activities, as: :subject, dependent: :destroy, class_name: "Business::Activity"
    has_many :lead_stages, class_name: "Business::LeadStage", dependent: :destroy
    has_many :messages, class_name: "Business::Message", dependent: :destroy
    has_one :surgery, class_name: "Business::Surgery", dependent: :destroy
    has_one :consultation, class_name: "Business::Consultation", dependent: :destroy
    has_one :treatment, :class_name => 'Business::Treatment', dependent: :destroy

    embeds_many :lead_photos, class_name: 'Business::LeadPhoto', :cascade_callbacks => true
    accepts_nested_attributes_for :lead_photos, class_name: 'Business::LeadPhoto'

    accepts_nested_attributes_for :tasks

    #this field is what tracks the booked procedure
    field :interested_in, type: String, default: nil
    field :stage, type: String, default: 'inquiry'
    field :stage_lifecycle, type: Array, default: []
    field :created_by, type: String, default: nil

    #source tracks lead source
    field :source, type: String, default: nil
    field :site, type: String, default: nil
    field :financing, type: String, default: nil
    field :budget, type: String, default: nil
    field :interest_level, type: String, default: nil

    field :planned_surgery_date, type: String, default: nil
    field :appointment_timeframe, type: String, default: nil
    field :appointment_type, type: String, default: nil

     # discontinue auto communication
    field :auto_communicate, type: Boolean, default: true

    field :photos_requested, type: Boolean, default: false
    field :motivation, type: String, default: nil



    field :interested_procedure, type: String, default: nil

    field :second_interest, type: String, default: nil
    field :second_interest_procedure, type: String, default: nil
    field :second_procedure_cost, type: Integer, default: 0

    field :referral, type: String, default: nil



    field :value, type: Integer, default: nil
    field :account_rep_id, type: String, default: nil

    field :requested_appointment_timeframe, type: String, default: nil
    field :type, type: String, default: "surgical"
    field :first_name, type: String, default: nil
    field :last_name, type: String, default: nil
    field :full_name, type: String, default: nil
    field :email, type: String, default: nil
    field :alt_email, type: String, default: nil
    field :phone, type: String, default: nil

    field :search_keys, type: Array, default: []
    field :message_id, type: String, default: nil

    field :questionnaire_id, type: String, default: nil
    field :questionnaire_sent, type: Boolean, default: false
    field :questionnaire_filled, type: Boolean, default: false
    field :questionnaire_viewed, type: Boolean, default: false
    field :search_keys, type: Array, default: []
    field :consultation_date, type: Date, default: nil
    field :procedure_date, type: Date, default: nil

    #### this data is meant to help track the lead's progression from incoming to surgery
    field :cancelled_consult, type: Boolean, default: false
    field :no_show, type: Boolean, default: false
    field :consultation_date, type: Date, default: nil

    field :interested_procedure, type: String, default: nil
    field :procedure_cost, type: Integer, default: 0
    field :second_interest, type: String, default: nil
    field :second_interest_procedure, type: String, default: nil
    field :second_procedure_cost, type: Integer, default: 0
    field :cancelled_surgery, type: Boolean, default: false
    field :procedure_date, type: Date, default: nil
    field :surgery_cost, type: Integer, default: 0
    field :surgery_completed, type: Boolean, default: false

    field :appointment_time_of_day, type: String, default: nil
    field :requested_appointment_day, type: DateTime, default: nil
    field :referral, type: String, default: nil
    field :value, type: Integer, default: nil
    field :account_rep_id, type: String, default: nil
    field :expectations, type: String, default: nil
    field :extra_questions, type: String, default: nil
    field :alt_phone, type: String, default: nil

    #### I would like to eliminate these fields theyre redundant and not needed most of them exist in the lead's contact
    field :position, type: Integer, default: nil
    field :score, type: String, default: nil
    field :nickname, type: String, default: nil
    field :note, type: String, default: nil
    field :status, type: String, default: nil
    field :lifestyle, type: String, default: nil
    field :events, type: String, default: nil
    field :address, type: String, default: nil
    field :city, type: String, default: nil
    field :state, type: String, default: nil
    field :zip, type: String, default: nil
    field :country, type: String, default: nil
    field :dob, type: String, default: nil
    field :date_of_birth, type: DateTime, default: nil
    field :bra_size, type: String, default: nil
    field :weight, type: String, default: nil
    field :height, type: String, default: nil
    field :gender, type: String, default: nil
    field :medications, type: String, default: nil
    field :medical_conditions, type: String, default: nil
    field :surgical_history, type: String, default: nil
    field :allergies, type: String, default: nil
    field :smoker, type: String, default: nil
    field :kids, type: Boolean, default: false
    field :spouse, type: Boolean, default: false
    field :children, type: String, default: nil
    field :last_pregnancy_date, type: String, default: nil
    field :consult_note, type: String, default: nil
    field :opticall, type: Boolean, default: false
    field :nurse_id, type: String, default: nil

    field :message_id, type: String, default: nil


    index({ search_keys: 1 }, { background: true })

    after_create :set_motivation
    before_save :set_full_name
    before_save :downcase_fields
    after_save :set_type
    after_save :stage_check

########This will be commented out
    after_save :update_procedure_detail

    def set_full_name
      self.full_name = self.name
    end

    def name
      [self.first_name, self.last_name].reject{|i| i.blank?}.join(' ').titleize
    end

    def set_type
      if self.interested_in.present?
        org = self.organization
        pro = org.procedures.where(slug_value: self.interested_in.parameterize('_')).first
        return if pro.nil?
        if pro.surgical
          self.set(type: "surgical")
        elsif pro.medspa
          self.set(type: "injection")
        end
      end
    end

    def set_motivation
      if self.contact.present?
        if self.contact.questionnaire.present?
          self.motivation = self.contact.questionnaire.motivation
        end
      end
    end

    def age
      begin
          if !self.date_of_birth.nil?
              dob = self.date_of_birth
              now = Time.now.utc.to_date
              now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
          end
      rescue
          return nil
      end
    end

    def downcase_fields
      self.first_name = self.first_name.downcase unless self.first_name.nil?
      self.last_name = self.last_name.downcase unless self.last_name.nil?
      self.email = self.email.downcase unless self.email.nil?
    end

    def self.receptionist_stages
        where(:stage => 'inquiry')
    end

    def self.stage_selection(stage)
      if stage == nil || stage.strip == ""
        scoped
      else
        where(:stage => stage)
      end
    end

    def self.coordinator_stages
        where(:stage.nin => ['cold','disqualified','archive'])
    end

    def self.other_stages
        where(:stage.nin => ['cold','disqualified','archive'])
    end

    def self.column_names
        self.attribute_names
    end

    def start_time
        self.consultation_date
    end

    def stage_check
      if self.stage_changed?
        self.tasks.update_all(stage: "completed")
        self.tasks.update_all(completed_by: "stage promotion")
        self.push(stage_lifecycle: { :stage => self.stage, :timestamp => Time.now })
      end
    end

    def self.search(search)
      if search == nil || search.strip == ""
        scoped
      else
        any_of({:first_name => search}, {:last_name => search}, {:email => search}, {:phone => search})
      end
    end

    def self.coordinator_search(coordinator)
      if coordinator == "" || coordinator == nil
        scoped
      else
        where(:user => coordinator)
      end
    end

    def self.creator_search(user)

      if user == "" || user == nil
        scoped
      else
        where(:created_by => user)
      end
    end

    def self.date_range(start_date, end_date)
      if start_date == "" || end_date == "" || start_date == nil || end_date == nil
        scoped

      else
        starting_date = Date.strptime(start_date, '%m/%d/%Y')
        ending_date = Date.strptime(end_date, '%m/%d/%Y')
        where(:created_at.gte => starting_date,
              :created_at.lte => ending_date)
      end
    end

    def self.analytics_date_range(start_date, end_date)
      where(:created_at.gte => start_date, :created_at.lte => end_date)
    end

    def self.message_count
      self.messages.count
    end

#### so will this
    def self.consultation_date_range(start_date, end_date)
      if start_date == "" || end_date == "" || start_date == nil || end_date == nil
        scoped
      else
        starting_date = Date.strptime(start_date, '%m/%d/%Y')
        ending_date = Date.strptime(end_date, '%m/%d/%Y')
        where(:consultation_date.gte => starting_date,
              :consultation_date.lte => ending_date)
      end
    end

    def self.procedure_date_range(start_date, end_date)
      if start_date == "" || end_date == "" || start_date == nil || end_date == nil
        scoped
      else
        starting_date = Date.strptime(start_date, '%m/%d/%Y')
        ending_date = Date.strptime(end_date, '%m/%d/%Y')
        where(:procedure_date.gte => starting_date,
              :procedure_date.lte => ending_date)
      end
    end

    def update_procedure_detail
        if self.interested_in.present? && (procedure = Business::Procedure.where(slug_value: interested_in.underscore.to_sym, organization_id: organization_id).first).present?
            self.interested_procedure = procedure.name
            self.procedure_cost = procedure.cost.to_i
        end

		    if self.second_interest.present? && (procedure = Business::Procedure.where(slug_value: second_interest.underscore.to_sym, organization_id: organization_id).first).present?
            self.second_interest_procedure = procedure.name
            self.second_procedure_cost = procedure.cost.to_i
        end
    end

    def procedure_name
        if self.interested_in.present? && !self.interested_procedure.present? && (procedure = Business::Procedure.where(slug_value: interested_in.underscore.to_sym, organization_id: organization_id).first).present?
            procedure.name
        elsif self.interested_in.present? && self.interested_procedure.present?
            self.interested_procedure
        end
    end

    def second_procedure_name
        if self.second_interest.present? && !self.second_interest_procedure.present? && (procedure = Business::Procedure.where(slug_value: second_interest.underscore.to_sym, organization_id: organization_id).first).present?
            procedure.name
        elsif self.second_interest.present? && self.second_interest_procedure.present?
            self.second_interest_procedure
        end
    end

    def self.to_csv
        CSV.generate do |csv|
          csv << ["First", "Middle", "Last", "Informal", "Gender", "BirthDate", "DateOfContact", "Chartnumber", "SSN", "Address1", "Address2", "City", "State", "Zip", "Workphone", "WorkExt", "HomePhone", "HomeExt", "Fax", "OtherPhone", "Email", "Email2"] ## Header values of CSV
          all.each do |lead|
            csv << [lead.first_name, nil, lead.last_name, nil, lead.gender, lead.dob, lead.requested_appointment_day, nil, nil, lead.address, nil, lead.city, lead.state, lead.zip, lead.phone, nil, nil, nil, nil, lead.alt_phone, lead.email, lead.alt_email] ##Row values of CSV
          end
        end
    end

    def message_count
      self.messages.count
    end

    def self.booked_consult
      where(:consultation.nin => [nil, ""])
    end

    def cached_message_count
      Rails.cache.fetch([self, "messages_count"]) do
        messages.count
      end
    end

    def cached_name
      Rails.cache.fetch([self, "name"]) do
        name
      end
    end

    def cached_user_name
      Rails.cache.fetch([self, "user_name"]) do
        user.full_name
      end
    end

    def cached_created_at
      Rails.cache.fetch([self, "created_at"]) do
        created_at
      end
    end

    def cached_stage
      Rails.cache.fetch([self, "stage"]) do
        stage
      end
    end

    def cached_source_name
      Rails.cache.fetch([self, "source_name"]) do
        self.source.name.titleize if self.source
      end
    end

    end
    ## Class End
end
##Module end
