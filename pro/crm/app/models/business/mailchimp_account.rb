class Business::MailchimpAccount
  include Mongoid::Document
  include Mongoid::Timestamps

  field :api_key, type: String

  belongs_to :organization, :class_name => 'Business::Organization'
end
