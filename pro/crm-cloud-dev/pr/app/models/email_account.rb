class EmailAccount < ActiveRecord::Base
  
  attr_accessible :access_token, :email, :expires, :expires_at, :expires_in, :provider, :refresh_token
  belongs_to :user

  validates :provider, :expires_at, presence: true, allow_blank: false
  validates :email, :refresh_token, :access_token, presence: true, allow_blank: false, uniqueness: true
  
  def to_params
    {
        refresh_token: refresh_token,
        client_id: MAILBOX_CREDENTIALS["client_id"],
        client_secret: MAILBOX_CREDENTIALS["client_secret"],
        grant_type: 'refresh_token'
    }
  end

  def request_token_from_google
    url = URI('https://accounts.google.com/o/oauth2/token')
    Net::HTTP.post_form(url, self.to_params)

  end

  def refresh_access_token!
    response = request_token_from_google
    data = JSON.parse(response.body)
    self.update_attributes({access_token: data['access_token'], expires_at: (Time.now + (data['expires_in'].to_i).seconds).to_i})
  end

  def access_token_expired?
    self.expires && (self.expires_at < Time.now.to_i)
  end

  def fresh_token
    refresh_access_token! if access_token_expired?
    access_token
  end

end
