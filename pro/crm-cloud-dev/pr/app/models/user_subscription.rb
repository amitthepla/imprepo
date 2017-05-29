class UserSubscription < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user
  attr_accessible :organization_id, :user_id, :btprofile_id, :btsubscription_id, :cancel_date, :cc_token, :is_active, :is_cancel, :is_updown, :next_billing_date, :payment_status, :price, :storage_limit, :subscription_id, :subscription_start_date, :user_limit, :is_cancel_payment_fail

  scope :active, lambda {where("is_active = ?", true)}  

  after_save :update_org_data
  after_save :adjust_org_user_limit, :if => :is_active_changed?


  def update_org_data
 	  # self.organization.update_column(:is_sub_active, self.is_active) 
 	  # if self.is_updown == 'started'
 	  # 	self.organization.update_attributes :current_sub_id => self.id, :is_sub_active => self.is_active, :current_user_limit => self.user_limit #, :trial_expires_on => Time.now
 	  # else
 	  self.organization.update_attributes :current_sub_id => self.id, :is_sub_active => self.is_active, :current_user_limit => self.user_limit
 	  # end
  end

  def adjust_org_user_limit  	  	
  	  self.organization.update_column(:current_user_limit, nil)  unless self.is_active
  end
  
end
