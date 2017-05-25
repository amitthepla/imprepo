module Business
  class LeadStage
  	include Mongoid::Document
    include Mongoid::Timestamps
    belongs_to :lead, class_name: "Business::Lead" ,index: true
    field :stage, type: String, default: nil
    field :timestamp, type: Date, default: nil

  end
end