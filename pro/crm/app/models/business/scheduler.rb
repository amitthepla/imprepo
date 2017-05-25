module Business
  class Scheduler
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :organization, class_name: "Business::Organization"

    field :scheduled_time, type: DateTime, default: nil
    field :state, type: Boolean, default: false
    field :object_id, type: String, default: nil
    field :type, type: String, default: nil
  end
end