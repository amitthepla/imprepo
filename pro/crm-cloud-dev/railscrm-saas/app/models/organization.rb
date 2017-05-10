class Organization < ActiveRecord::Base
  attr_accessible  :beta_account_id, :deleted_at, :email, :is_active, :is_premium, :name, :size_id, :total_users, :website,:company_strength,:users,:description,:address_attributes,:phone_attributes,:time_zone,:auth_token, :organization_type,:current_sub_id ,:is_sub_active , :current_user_limit,:trial_expires_on, :is_trial_expired , :user_allowed_by_admin, :extend_trial_days
  
  has_many :priority_types, :dependent => :destroy
  has_many :deal_statuses, :dependent => :destroy
  has_many :contacts, :dependent => :destroy
  has_many :individual_contacts, :dependent => :destroy
  has_many :company_contacts, :dependent => :destroy
  has_many :sources, :dependent => :destroy
  has_many :deals, :dependent => :destroy
  has_many :task_types, :dependent => :destroy
  has_many :tasks, :dependent => :destroy
  has_many :industries, :dependent => :destroy
  has_many :deal_moves, :dependent => :destroy
  has_many :attachments, :class_name => "Note",:dependent => :destroy
  has_many :roles, :dependent => :destroy
  has_many :attention_deals, :dependent => :destroy
  has_many :activities, :dependent => :destroy
  has_many :notes, :dependent => :destroy
  has_many :deal_industries, :dependent => :destroy
  has_many :user_preferences, :dependent => :destroy
  has_many :deal_sources, :dependent => :destroy
  has_many :web_forms, :dependent => :destroy
  #has_many :feed_keywords, :dependent => :destroy
  belongs_to :company_strength,:class_name=>"CompanyStrength",:foreign_key=>"size_id"

  has_many :task_priority_types , :dependent => :destroy
  has_many :api_integrations, dependent: :destroy
  has_one :address, :as => :addressable,:class_name=>"Address", :dependent => :destroy
  has_one :phone, :as => :phoneble,:class_name=>"Phone", :dependent => :destroy
  has_many :user_subscriptions
  has_many :transactions
  #callback to save some default data while creating organizations
  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :phone

  after_create :insert_default_data
  # after_save :inactive_org_users, :if => :is_trial_expired_changed?
  # after_save :inactive_org_users, :if => :is_sub_active_changed?
  
  has_many :users,:foreign_key=>"organization_id", :dependent => :destroy
  has_many :invoices, :dependent => :destroy
  
   attr_accessor :street, :state, :country, :city, :zip,:phone_no,:time_zone
  def insert_default_data 
    p 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXxxxx'
    p 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXxxxx'
    p 'Organization Created'
    p 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXxxxx'
    p 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXxxxx'
    
    #Update auth_token where auth_token is nil
    auth_key = "#{self.id}-#{self.name}-#{self.created_at.strftime('%Y-%m-%d %H:%M:%S')}"
    self.update_column :auth_token, Base64::encode64(auth_key)
    
    # Default lead status for organization
    @deal_status = DealStatus.where(:organization_id => 1)
      @deal_status.each do |deal_status|
        DealStatus.create(name: deal_status.name, original_id: deal_status.original_id, organization_id: self.id)
     end
    #1 - Hot, 2 - Warm, 3 - cold 
    priority = {"1" => "Hot", "2" => "Warm", "3" => "Cold"}   
    priority.each_pair do |key, value|    
      PriorityType.create :organization_id => self.id, :original_id => key, :name => value
    end  
   
    #deafult task types for organization
    task_types = ["Appointment","Billing","Call","Documentation","Email","Follow-up","Meeting","None","Quote","Thank-you"]
    task_types.each do |task_name|
        TaskType.create :organization_id => self.id, :name => task_name
    end
    
    ##1 - New Deals, 2 - Qualified, 3 - Not Qualified, 4 - Won, 5 - Lost, 6 - Junk 
    #commented for new deal stages
    #priority = {"1" => "New Deals", "2" => "Qualified", "3" => "Not Qualified", "4" => "Won", "5" => "Lost", "6" => "Junk"}
    #priority.each_pair do |key, value|    
    #  DealStatus.create :organization_id => self.id, :original_id => key, :name => value
    #end
    # deal_stages = DealStage.all
    # deal_stages.each do |dealstage|
    #   DealStatus.create :organization_id => self.id, :original_id => dealstage.original_id, :name => dealstage.name
    # end
	
    ##deafult roles for organization
    roles = ["Sales","Lead Generator"]
    roles.each do |role_name|
        Role.create :organization_id => self.id, :name => role_name
    end
    self.update_column :trial_expires_on, Time.now+2.days
  end  

  # def inactive_org_users
  #    puts "-------------------> inactive_org_users"
  #    p self.is_trial_expired
  #    p self.is_sub_active
  #    p self.is_trial_expired || self.is_sub_active
  #    if self.is_trial_expired || self.is_sub_active
  #     self.users.where(["admin_type not in (?)", [0,1]]).update_all is_active: false
  #    end

  #    # sssssssssssssss
  # end 

  def hot_priority
    return self.priority_types.find(:first,:conditions=>["original_id = ? ",1])
  end
  def warm_priority
    return self.priority_types.find(:first,:conditions=>["original_id = ? ",2])
  end
  def cold_priority
    return self.priority_types.find(:first,:conditions=>["original_id = ? ",3])
  end
  def get_deal_status(original_id)
    dlstatus= self.deal_statuses.where("original_id = ?",original_id)
    return dlstatus
  end
  def filter_deal_status(deal_status,org_id)
   deal_status = DealStatus.get_deal_name(deal_status,org_id)
   return deal_status
   #return  self.deal_statuses.where("original_id = 1").first
  end
  def incoming_deal_status
   return  self.deal_statuses.where("original_id = 1").first
  end
  def qualify_deal_status
   return  self.deal_statuses.where("original_id = 2").first
  end
  def not_qualify_deal_status
   #return  self.deal_statuses.where("original_id = 3").first
   return  self.deal_statuses.where("name = ?", "Not Qualified").first
  end
  def won_deal_status
   return  self.deal_statuses.where("original_id = 4").first
  end
  def lost_deal_status
   return  self.deal_statuses.where("original_id = 5").first
  end
  def junk_deal_status
   return  self.deal_statuses.where("original_id = 6").first
  end
  #Added new deal statuses
  def no_contact_deal_status
   return  self.deal_statuses.where("original_id = 7").first
  end
  def follow_up_required_deal_status
   return  self.deal_statuses.where("original_id = 8").first
  end
  def follow_up_deal_status
   return  self.deal_statuses.where("original_id = 9").first
  end
  def quoted_deal_status
   return  self.deal_statuses.where("original_id = 10").first
  end
  def meeting_scheduled_deal_status
   return  self.deal_statuses.where("original_id = 11").first
  end
  def forecasted_deal_status
   return  self.deal_statuses.where("original_id = 12").first
  end
  def waiting_for_project_requirement_deal_status
   return  self.deal_statuses.where("original_id = 13").first
  end
  def proposal_deal_status
   return  self.deal_statuses.where("original_id = 14").first
  end
  def estimate_deal_status
   return  self.deal_statuses.where("original_id = 15").first
  end 
  def get_deal_status(status_type)
    case status_type
      when 'new','incoming','lead'
        ds = self.deal_statuses.where("original_id = 1").first
      when 'pipeline','qualify'
        ds = self.deal_statuses.where("original_id = 2").first
      when 'won'
        ds = self.deal_statuses.where("original_id = 3").first
      when 'lost'
        ds = self.deal_statuses.where("original_id = 4").first
      when 'not_qualify'
        ds = self.deal_statuses.where("original_id = 5").first
      when 'junk','dead'
        ds = self.deal_statuses.where("original_id = 6").first
      when 'nocontact','no_contact'
        ds = self.deal_statuses.where("original_id = 7").first
      when 'follow_up_required'
        ds = self.deal_statuses.where("original_id = 8").first
      when 'follow_up'
        ds = self.deal_statuses.where("original_id = 9").first
      when 'quoted'
        ds = self.deal_statuses.where("original_id = 10").first
      when 'meeting_scheduled'
        ds = self.deal_statuses.where("original_id = 11").first
      when 'forecasted'
        ds = self.deal_statuses.where("original_id = 12").first
      when 'waiting_for_project_requirement'
        ds = self.deal_statuses.where("original_id = 13").first
      when 'proposal'
        ds = self.deal_statuses.where("original_id = 14").first
      when 'estimate'
        ds = self.deal_statuses.where("original_id = 15").first
    end
  end

  def self.organization_list
    select("id, name, email, created_at, total_users").order("created_at desc")
  end
  
  def get_location
    location=""
    if (address = self.address).present?
      location += address.address + ", " if address.address.present?
      location += address.city + ", " if address.city.present?
      location += address.state + ", " if address.state.present?
      location += address.country.name if address.country.present?
    end
    return location
  end

  # Retrive all Attachments of current organization
  def all_attachments notes=nil
    if notes == nil
      notes = self.notes.collect{|note| note.id}
      NoteAttachment.where(note_id: notes).order("id DESC")
    else
      NoteAttachment.where(note_id: notes).order("id DESC")
    end
  end

  def trial_expired?
    self.is_trial_expired
  end

  def trail_days_left_in_words
    # t = ((((self.trial_expires_on.to_datetime)-Time.now.to_datetime)/(24.0*60*60)).round)
    t = ((DateTime.parse(self.trial_expires_on.to_s) - DateTime.parse(Time.now.to_s))).to_i
    case t 
    when 0
      "Trial will expire today"
    else
      "#{t} Day(s) left on your trial"
    end
  end

  def trail_days_left_in_days
    t = ((DateTime.parse(self.trial_expires_on.to_s) - DateTime.parse((Time.now).to_s))).to_i
    return t
  end

  def active_users
    self.users.where("invitation_token IS ?", nil).where("confirmation_token IS ?", nil)
  end 

end