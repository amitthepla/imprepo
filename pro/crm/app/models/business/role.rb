module Business
  class Role
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :organization, class_name: "Business::Organization"
    has_one :permission, :class_name => 'Business::Permission', dependent: :destroy
    # has_many :users

    field :name, 		type: String, default: nil
    field :type, 		type: String, default: nil
    field :visibility,	type: String, default: "public"


  end
end
