class Business::Treatment
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :injection_procedures, :class_name => 'Business::InjectionProcedure', dependent: :destroy
  belongs_to :lead, :class_name => 'Business::Lead'
  belongs_to :created_by, :class_name => 'User'

  field :name, type: String, default: 'New Treatment'
  field :note, type: String
  field :treatment_date, type: Time, default: Time.now.utc

end
