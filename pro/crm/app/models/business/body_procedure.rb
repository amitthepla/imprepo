class Business::BodyProcedure
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, 		    type: String, default: nil
  field :cost, 		    type: Integer, default: nil
  field :details, 		type: String, default: nil
  field :slug_value,	type: String, default: nil

  belongs_to :procedure_mapping, :class_name => 'Business::ProcedureMapping'
end
