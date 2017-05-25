module Business
  class PhoneMessage
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :organization, class_name: "Business::Organization", index: true
    belongs_to :user, index: true

    has_many :notes, as: :subject, dependent: :destroy, class_name: "Business::Note"

    validates_presence_of :from

    field :from, type: String, default: nil
    field :callback_number, type: String, default: nil
    field :email, type: String, default: nil
    field :message, type: String, default: nil
    field :surgery_date, type: DateTime, default: nil
    field :stage, type: String, default: nil
    field :created_by, type: BSON::ObjectId, default: nil
    field :archived, type: Boolean, default: false
    
  end
end
