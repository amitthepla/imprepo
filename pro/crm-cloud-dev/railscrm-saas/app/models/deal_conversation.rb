class DealConversation < ActiveRecord::Base
  attr_accessible :message, :subject,  :deal_id, :user_id, :organization_id

  belongs_to :user
  belongs_to :deal
  belongs_to :organization
  has_many :deal_attachments
end