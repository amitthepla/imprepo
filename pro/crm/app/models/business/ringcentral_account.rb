require 'base64'
class Business::RingcentralAccount
  include Mongoid::Document
  include Mongoid::Timestamps

  field :access_key, type: String
  field :secret_key, type: String
  field :phone, type: String
  field :password, type: String
  field :access_token, type: String
  field :expires_at, type: Integer, default: (Time.now - 10.seconds).to_i
  field :last_fetched, type: Time, default: nil

  belongs_to :organization, :class_name => 'Business::Organization'

  validates :access_key, :secret_key, :phone, :password, presence: true, allow_blank: false

  before_create :encrypt_password

  def encrypt_password
    self.password = Base64.encode64(self.password)
  end

  def to_params
    {
        access_key: access_key,
        secret_key: secret_key,
        phone: phone,
        password: Base64.decode64(password),
        last_fetched: last_fetched
    }
  end

  def refresh_token!
    begin
      client = RingCentralSdk.new(
          self.access_key,
          self.secret_key,
          RingCentralSdk::RC_SERVER_PRODUCTION,
          {username: self.phone, extension: '', password: Base64.decode64(self.password)}
      )

      self.update_attributes({expires_at: client.token.expires_at, access_token: client.token.token})
    rescue
      nil
    end
  end

  def access_token_expired?
    self.expires_at < Time.now.to_i
  end
end
