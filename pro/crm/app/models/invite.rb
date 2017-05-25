class Invite
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :organization, class_name: "Business::Organization"

  validates :email, :presence => true, :uniqueness => true

  field :token, type: String, default: nil
  field :email, type: String, default: nil
  field :first_name, type: String, default: nil
  field :last_name, type: String, default: nil
  field :invited_by, type: String, default: nil
  field :role, type: BSON::ObjectId, default: nil
  field :is_active, type: Boolean, default: false

  before_create :generate_token
  after_create :send_invite

  private

  def generate_token
    self.token = SecureRandom.uuid
  end

  def send_invite
    require 'mandrill'
    mandrill_api = Mandrill::API.new
    message = {
        :subject => "Hello, #{first_name}! You have been invited to join #{organization.company_name} by #{self.invited_by}",
        :from_name => organization.company_name,
        :text => "Hello, #{first_name}! You have been invited to join #{organization.company_name}",
        :to => [
            {
                :email => "#{self.email}",
                :name => "#{self.first_name} #{self.last_name}"
            }
        ],
        :html => "<html>Hi #{first_name}, You have been invited to join #{organization.company_name}. Please click the following link to get started. <a href=\"https://crm.4beauty.net/invite/#{self.token}\">Accept Invite</a> or paste the following link in your browser: https://crm.4beauty.net/invite/#{self.token} </html>",
        # :from_email => organization.notification_address
        :from_email => 'notify@theconversiondoctor.com'
    }
    mandrill_api.messages.send(message)
  end
end
