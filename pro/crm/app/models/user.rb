class User
  include Mongoid::Document
  include Mongoid::Timestamps

  authenticates_with_sorcery!

  belongs_to :organization, class_name: 'Business::Organization'
  # has_many :roles, class_name: "Business::Role"

  has_many :leads, class_name: 'Business::Lead'
  has_many :notes, class_name: 'Business::Note'
  has_many :tasks, class_name: 'Business::Task'
  has_many :events, class_name: 'Business::Event'
  has_many :phone_messages, class_name: 'Business::PhoneMessage'
  has_many :surgeries, class_name: "Business::Surgery"
  has_many :consultations, class_name: "Business::Consultation"
  has_many :messages, class_name: "Business::Message", dependent: :destroy
  has_many :treatments, :class_name => 'Business::Treatment'
  has_one :email_account

  has_many :conversations, as: :receiver

  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }

  # validates_presence_of :password, :on => :create
  validates :email, :presence => true, :uniqueness => true

  field :is_super_admin, type: Boolean, default: false
  field :first_name, type: String, default: nil
  field :last_name, type: String, default: nil
  field :phone, type: Integer, default: nil
  field :title, type: String, default: nil

  field :username, type: String, default: nil
  field :avatar, type: String, default: nil
  field :type, type: String, default: nil
  field :push_channel_id, type: String, default: nil

  field :view, type: String, default: 'Receptionist'
  field :is_active, type: Boolean, default: true
  field :task_setting, type: String, default: 'universal'
  field :stages, type: Array, default: []
  field :roles, type: Array, default: []
  field :task_visibility, type: String, default: 'own'
  field :twilio_phone, type: String, default: nil
  field :is_online, type: Boolean, default: false
  field :last_activity_time, type: Time, default: Time.now.utc

  # Added site admin
  field :site_admin, type: Boolean, default: false

  before_create do
    self.push_channel_id = SecureRandom.uuid
  end

  before_validation do |model|
    model.roles.reject!(&:blank?) if model.roles
  end

  def admin?
    self.is_super_admin
  end

  def full_name
    "#{self.first_name} #{self.last_name}".titleize
  end

  def initials
    "#{self.first_name[0, 1]}#{self.last_name[0, 1]}"
  end

  def is_public?
    task_visibility == 'public'
  end


  def can_access?(controller, action)
    admin = organization.roles.where({name: 'Administrator'}).first
    sc = organization.roles.where({name: 'Sales Coordinator'}).first
    rcp = organization.roles.where({name: 'Receptionist'}).first
    anly = organization.roles.where({name: 'Analytics'}).first
    pma = organization.roles.where({name: 'Phone Message Access'}).first
    pro = organization.roles.where({name: "Pre-Op Nurse"}).first
    pa = organization.roles.where({name: "Physician Assistant"}).first
    surgeon = organization.roles.where({name: "Surgeon"}).first
    pro_roles = %w(business/leads business/tasks business/phone_messages business/emails business/notes business/contacts sessions business/consultations business/surgeries)
    sc_roles_c = %w(business/leads business/tasks business/phone_messages business/notes business/emails business/contacts sessions business/consultations business/surgeries)
    rec_roles_c = %w(business/leads business/tasks business/phone_messages business/notes business/emails business/contacts sessions business/consultations business/surgeries)
    analytics_roles = %w(business/leads business/dashboard business/tasks business/notes business/phone_messages business/emails business/contacts sessions business/consultations business/surgeries)
    pma_roles_c = %w(business/phone_messages business/notes business/emails business/contacts sessions business/consultations business/surgeries)
    # pma_roles_a = %w(surgery_log consult_log calendar)

    if roles.include?(admin.id.to_s)
      true
    elsif roles.include?(pa.id.to_s)
      true
    elsif roles.include?(surgeon.id.to_s)
      true
    elsif roles.include?(sc.id.to_s)
      sc_roles_c.include?(controller)
    elsif roles.include?(rcp.id.to_s)
      rec_roles_c.include?(controller)
    elsif roles.include?(anly.id.to_s)
      analytics_roles.include?(controller)
    elsif roles.include?(pma.id.to_s)
      pma_roles_c.include?(controller)
    elsif roles.include?(pro.id.to_s)
      pro_roles.include?(controller)
    else
      false
    end
  end

  def new_lead_tasks(filtered_tasks, stage)
    if stage.present?
      puts 'PRESENT'
      filtered_tasks.in(lead_id: Business::Lead.stage_selection(stage).pluck(:id)).incomplete_tasks
    else
      filtered_tasks.in(lead_id: Business::Lead.receptionist_stages.pluck(:id)).incomplete_tasks
    end
  end

  def coordinator_lead_tasks(filtered_tasks, stage)
    if stage.present?
      puts 'PRESENT'
      filtered_tasks.in(lead_id: leads.stage_selection(stage).pluck(:id)).incomplete_tasks
    else
      filtered_tasks.in(lead_id: leads.coordinator_stages.pluck(:id)).incomplete_tasks
    end
  end

  def lead_tasks(filtered_tasks, stage)
    if stage.present?
      puts 'PRESENT'
      filtered_tasks.in(lead_id: leads.stage_selection(stage).pluck(:id)).incomplete_tasks
    else
      filtered_tasks.in(lead_id: leads.other_stages.pluck(:id)).incomplete_tasks
    end
  end

  def to_listing(user_id)
    condition = {'$or' => [{sender: self.id.to_s, receiver_id: user_id}, {sender: user_id, receiver_id: self.id.to_s}]}
    conversation = Conversation.where(condition).order_by(created_at: 'ASC').last
    unread_count = (conversation.present? && conversation.user_activities[user_id].present?) ? conversation.conversation_replies.unread_messages(conversation.user_activities[user_id], user_id).count : 0

    {
        id: id.to_s,
        is_online: is_online,
        full_name: full_name,
        unread: unread_count,
        type: 'individual'
    }

  end

  def unread_threads
    condition = {'$or' => [{sender: self.id.to_s}, {receiver_id: self.id.to_s}]}
    cnvs = Conversation.where(condition).order_by(created_at: 'ASC')
    channels = []
    cnvs.each do |cnv|
      cnt = (cnv.user_activities[self.id.to_s].present? ? cnv.conversation_replies.unread_messages(cnv.user_activities[self.id.to_s], self.id.to_s).count : 0)
      if cnt > 0
        channels << cnv.channel
      end
    end
    channels
  end

end
