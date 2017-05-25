module Business
  class BankProfile
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :organization, class_name: "Business::Organization"

    field :first_name, type: String, default: nil
    field :last_name, type: String, default: nil
    field :email, type: String, default: nil
    field :score, type: Hash, default: {}
    field :referral, type: String, default: nil
  end
end