module Business
  class Contact
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :organization, class_name: "Business::Organization", index: true
    has_many :leads, class_name: "Business::Lead", dependent: :destroy
    has_many :events, class_name: "Business::Event", dependent: :destroy
    has_many :messages, class_name: "Business::Message", dependent: :destroy
    has_many :surgeries, class_name: "Business::Surgery", dependent: :destroy
    has_many :consultations, class_name: "Business::Consultation", dependent: :destroy
    has_one :questionnaire, class_name: "Business::Questionnaire", dependent: :destroy, autosave: true

    accepts_nested_attributes_for :questionnaire

    validates_presence_of :first_name, :email
    validates_uniqueness_of :email

    field :public_token, type: String, default: nil
    field :external_record_id, type: String, default: nil
    field :account_rep_id, type: BSON::ObjectId, default: nil
    field :referral, type: String, default: nil

    field :first_name, type: String, default: nil
    field :last_name, type: String, default: nil

    field :email, type: String, default: nil
    field :alt_email, type: String, default: nil

    field :phone, type: String, default: nil
    field :alt_phone, type: String, default: nil

    field :address, type: String, default: nil
    field :alt_address, type: String, default: nil
    field :city, type: String, default: nil
    field :state, type: String, default: nil
    field :zip, type: String, default: nil
    field :country, type: String, default: nil

    field :driver_license_number, type: String, default: nil
    field :driver_license_state, type: String, default: nil

    field :bra_size, type: String, default: nil
    field :dress_size, type: String, default: nil

    field :weight, type: String, default: nil
    field :height, type: String, default: nil
    field :gender, type: String, default: nil

    field :marital_status, type: String, default: nil

    field :employer, type: String, default: nil
    field :occupation, type: String, default: nil
    field :business_phone, type: String, default: nil

    field :emergency_contact_first_name, type: String, default: nil
    field :emergency_contact_last_name, type: String, default: nil
    field :emergency_contact_phone, type: String, default: nil
    field :emergency_contact_relationship, type: String, default: nil

    field :date_of_birth, type: DateTime, default: nil
    field :birth_month, type: Integer, default: nil
    field :birth_day, type: Integer, default: nil

    field :recieve_marketing, type: Boolean, default: true
    field :preffered_contact_method, type: String, default: nil

    field :preffered_language, type: String, default: 'en'

    field :is_imported, type: Boolean, default: false
    field :is_organization, type: Boolean, default: false

    field :search_keys, type: Array, default: []

    before_save :clean_data,:update_search_keys,:set_birth_date

    before_create :generate_token

    after_create :create_questionnaire

    index({ search_keys: 1 }, { background: true })

    def full_name
      "#{self.first_name} #{self.last_name}"
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

    def dob
        self.date_of_birth.strftime("%m/%d/%Y") if !self.date_of_birth.nil?
    end

    def account_rep
        User.find(self.account_rep_id) if !self.account_rep_id.nil?
    end

    def email_coordinator_intro
    end

    def email_questionnaire
    end

    private
    def update_search_keys
        self.search_keys = [self.first_name ,self.last_name ,(self.phone.nil? ? nil : self.phone.gsub(/\D/, '')),self.email ,(self.date_of_birth.nil? ? nil : self.date_of_birth.strftime("%m/%d/%Y").gsub(/\D/, ''))]
    end

    def clean_data
        self.first_name.downcase.strip unless self.first_name.nil?
        self.last_name.downcase.strip unless self.last_name.nil?
        self.email.downcase.strip unless self.email.nil?
    end


    def set_birth_date
        dob = self.date_of_birth
        if !dob.nil?
            self.birth_month = dob.month
            self.birth_day = dob.day
        end
    end

    def generate_token
        self.public_token = SecureRandom.uuid if self.public_token.nil?
    end

    def create_questionnaire
        self.questionnaire = Business::Questionnaire.create unless self.questionnaire
    end
  end
end
