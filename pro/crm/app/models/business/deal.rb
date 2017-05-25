module Business
  class Deal
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :organization, class_name: "Business::Organization"
    belongs_to :contact, class_name: "Business::Contact"
    has_many :notes, as: :subject, dependent: :destroy, class_name: "Business::Note"
    has_many :activities, as: :subject, dependent: :destroy, class_name: "Business::Activity"

    field :status, type: String, default: nil
    field :stage, type: String, default: nil
    field :position, type: Integer, default: nil
    field :score, type: String, default: nil
    field :source, type: String, default: nil
    field :value, type: Integer, default: nil

    field :account_rep_id, type: String, default: nil
    field :sales_rep_id, type: String, default: nil
  end
end