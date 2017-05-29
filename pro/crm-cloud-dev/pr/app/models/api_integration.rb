class ApiIntegration < ActiveRecord::Base
  attr_accessible :organization_id, :api_name, :account_id, :auth_token, :oauth_access_token, :url
  belongs_to :organization

  validates_presence_of :api_name, :account_id, :auth_token, :organization
  validates_presence_of :url, if: :is_zendesk_api?

  private

  def is_zendesk_api?
    self.api_name.downcase == 'zendesk'
  end
end
