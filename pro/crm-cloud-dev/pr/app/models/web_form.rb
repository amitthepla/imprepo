class WebForm < ActiveRecord::Base
  attr_accessible :email_to_all, :field_names, :form_html_code, :form_unique_id, :is_display_thank_you_page, :external_link, :source_id, :organization_id, :send_email_notification, :user_responsible, :is_active, :form_name
  belongs_to :organization
  belongs_to :user
  belongs_to :source
  after_create :save_form_unique_id
  has_many :deals

  def save_form_unique_id
  	unique_key = "#{self.id}-#{self.organization_id}-#{self.created_at.strftime('%Y-%m-%d %H:%M:%S')}"
  	self.update_column :form_unique_id, Digest::MD5.hexdigest(unique_key)
  end
  def user
    self.organization.users.where("id=?",self.user_responsible).first    
  end
end
