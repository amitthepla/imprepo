class Transaction < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user
  belongs_to :user_subscription
  attr_accessible :organization_id, :user_id, :user_subscription_id,:amount, :balance, :btsubscription_id, :invoice_id, :next_billing_date, :plan_id, :status, :ip, :subscription_price, :transaction_id, :transaction_type
  scope :by_success, lambda {where("transaction_type = ?", "subscription_charged_successfully")}

  after_save :update_user_subscription_payment_status 
  after_save :adjust_user_subscription_and_org_status_based_on_webhook_response, :if => :status_changed?

  after_create :generate_invoice_id
  
  #unique ID is generated
  def generate_invoice_id
    if (org_trans = self.organization.transactions).present?
      self.update_column(:invoice_id, org_trans.last.invoice_id + 1)
    else
      self.update_column(:invoice_id, 5001)
    end
  end

  def update_user_subscription_payment_status
  	self.user_subscription.update_attributes(:payment_status => self.status) 
  end

  def adjust_user_subscription_and_org_status_based_on_webhook_response
  	if self.transaction_type == "subscription_charged_successfully" || self.transaction_type == "subscription_went_active"
  		self.user_subscription.organization.update_attributes(:is_sub_active => true) 
        Notification.subscription_payment_success(self.transaction_type).deliver
    else
    	self.user_subscription.organization.update_attributes(:is_sub_active => false) 
      self.user_subscription.organization.users.where(["admin_type not in (?)", [0,1]]).update_all is_active: false
    	self.user_subscription.update_attributes(:is_active => false) 
        Notification.subscription_payment_error(self.transaction_type).deliver
  	end
  end
end

