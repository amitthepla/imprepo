module Business
  class Casting
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :organization, class_name: "Business::Organization"

    field :first_name, type: String, default: nil
    field :last_name, type: String, default: nil
    field :email, type: String, default: nil
    field :phone, type: String, default: nil
    field :gender, type: String, default: nil
	  field :preffered_language, type: String, default: 'en'
    field :casting_type, type: String, default: nil
    field :story, type: String, default: nil
  end
end
