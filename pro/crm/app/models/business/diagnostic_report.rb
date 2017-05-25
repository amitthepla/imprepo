class Business::DiagnosticReport
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :organization, class_name: 'Business::Organization'

  field :body, type: String, default: nil
  field :viewed, type: Boolean, default: false

end
