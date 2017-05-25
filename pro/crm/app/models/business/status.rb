module Business
  class Status
    include Mongoid::Document
    include Mongoid::Timestamps
    
    validates_presence_of :description

    belongs_to :organization, class_name: "Business::Organization"

    field :description, type: String, default: nil
    field :icon, type: String, default: nil
    field :color, type: String, default: nil

  end
end