module Business
  class Event
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :organization, class_name: "Business::Organization", index: true
    belongs_to :user, index: true
    belongs_to :contact, class_name: "Business::Contact", index: true

    field :title, type: String, default: nil
    field :description, type: String, default: nil
    field :start_time, type: DateTime, default: nil
    field :end_time, type: DateTime, default: nil
    field :type, type: String, default: nil
    field :status, type: String, default: nil
    field :resources, type: Array, default: []
    field :location, type: String, default: nil
  end
end