class Business::EmailAccount
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email, type: String
  field :access_token, type: String
  field :refresh_token, type: String
  field :expires, type: Boolean, default: true
  field :expires_in, type: Integer, default: 3600
  field :expires_at, type: Integer
  field :last_fetched_on, type: Time, default: nil

  belongs_to :organization, :class_name => 'Business::Organization'

  validates :expires_at, presence: true, allow_blank: false
  validates :email, :refresh_token, :access_token, presence: true, allow_blank: false, uniqueness: true

  def to_params
    {
        refresh_token: refresh_token,
        client_id: GOOGLE_NOTES_CLIENT_ID,
        client_secret: GOOGLE_NOTES_CLIENT_SECRET,
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

end
