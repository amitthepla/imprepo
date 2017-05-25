module Business
  class Organization
    include Mongoid::Document
    include Mongoid::Timestamps

    has_many :users, dependent: :destroy
    has_many :invites, dependent: :destroy
    has_many :sites, class_name: 'Business::Site', dependent: :destroy
    has_many :roles, class_name: 'Business::Role', dependent: :destroy
    has_many :permissions, :class_name => 'Business::Permission'
    has_many :contacts, class_name: 'Business::Contact', dependent: :destroy
    has_many :leads, class_name: 'Business::Lead', dependent: :destroy
    has_many :deals, class_name: 'Business::Deal', dependent: :destroy
    has_many :notes, class_name: 'Business::Note', dependent: :destroy
    has_many :tasks, class_name: 'Business::Task', dependent: :destroy
    has_many :task_settings, class_name: 'Business::TaskSetting', dependent: :destroy
    has_many :events, class_name: 'Business::Event', dependent: :destroy
    has_many :stages, class_name: 'Business::Stage', dependent: :destroy
    has_many :injection_products, class_name: 'Business::InjectionProduct', dependent: :destroy
    has_many :products, class_name: 'Business::Product', dependent: :destroy
    has_many :settings, class_name: 'Business::Setting', dependent: :destroy
    has_many :email_messages, class_name: 'Business::EmailMessage', dependent: :destroy
    has_many :statuses, class_name: 'Business::Status', dependent: :destroy
    has_many :bank_profiles, class_name: 'Business::BankProfile', dependent: :destroy
    has_many :phone_messages, class_name: 'Business::PhoneMessage', dependent: :destroy
    has_many :castings, class_name: 'Business::Casting', dependent: :destroy
    has_many :procedures, class_name: 'Business::Procedure', dependent: :destroy
    has_many :surgeries, class_name: "Business::Surgery", dependent: :destroy
    has_many :consultations, class_name: "Business::Consultation", dependent: :destroy
    has_many :sources, :class_name => 'Business::Source'
    has_many :messages, class_name: "Business::Message", dependent: :destroy

    has_many :diagnostic_reports, :class_name => 'Business::DiagnosticReport'
    has_many :analytics_reports, :class_name => 'Business::AnalyticsReport'
    has_many :health_check_reports, :class_name => 'Business::HealthCheckReport'
    has_one :email_account, :class_name => 'Business::EmailAccount'
    has_one :ringcentral_account, :class_name => 'Business::RingcentralAccount'
    has_one :mailchimp_account, :class_name => 'Business::MailchimpAccount'

    validates_presence_of :company_name

    after_create :default_data

    field :company_name, type: String, default: nil
    field :phone, type: Integer, default: nil
    field :address, type: String, default: nil
    field :city, type: String, default: nil
    field :state, type: String, default: nil
    field :zip, type: Integer, default: nil

    field :type, type: String, default: nil
    field :status, type: Boolean, default: false
    field :owner_id, type: BSON::ObjectId, default: nil
    field :notification_address, type: String, default: nil


    def admin_lead_tasks(filtered_tasks, stage)
      if stage.present?
        filtered_tasks.in(lead_id: leads.stage_selection(stage).pluck(:id)).incomplete_tasks
      else
        filtered_tasks.in(lead_id: leads.other_stages.pluck(:id)).incomplete_tasks
      end
    end

    protected

    def default_data
      # Setup stages
      #
      default_stages = [
          {name: 'Inquiry', description: 'This is where all qualified leads will go.', type: 'lead', position: 1},
          {name: 'Booked Consult', description: 'Leads that booked consult.', type: 'lead', position: 2},
          {name: 'Booked Surgery', description: 'Leads that booked surgery.', type: 'lead', position: 3},
          {name: 'Post-Op', description: 'Leads that completed surgery.', type: 'lead', position: 4},
          {name: 'Cold', description: 'All cold leads.', type: 'lead', position: 5},
          {name: 'Disqualified Leads', description: 'All disqualified leads.', type: 'lead', position: 6},
          {name: 'Archived', description: 'All Archived leads.', type: 'lead', position: 7},
          {name: 'New', description: 'All new tasks.', type: 'task', position: 1},
          {name: 'Pending', description: 'All pending tasks.', type: 'task', position: 2},
          {name: 'Completed', description: 'All completed Tasks.', type: 'task', position: 3},
          {name: 'Deleted', description: 'All Deleted Tasks.', type: 'task', position: 4}
      ]
      # Setup Roles
      #
      default_roles = [
          {name: 'Administrator'},
          {name: 'Sales Coordinator'},
          {name: 'Receptionist'},
          {name: 'Analytics'},
          {name: 'Physician Assistant'},
          {name: 'Surgeon'}
      ]

      default_stages.each do |stage|
        self.stages.create(stage)
      end

      default_roles.each do |role|
        self.roles.create(role)
      end

      self.stages.update_all(roles: [self.roles.where({name: 'Administrator'}).first.id.to_s])
    end

  end
end
