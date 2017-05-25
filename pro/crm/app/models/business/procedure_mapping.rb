class Business::ProcedureMapping
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :procedures, :class_name => 'Business::Procedure'

  field :name,                type: String, default: nil
  field :gender,              type: String, default: 'F'
  field :coordinates,         type: String, default: nil

end
