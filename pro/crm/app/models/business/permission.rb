module Business
  class Permission
    include Mongoid::Document
    include Mongoid::Timestamps

    field :stages, type: Array, default: []
    field :visibility, type: String, default: 'own'

    belongs_to :organization, :class_name => 'Business::Organization'
    belongs_to :role, :class_name => 'Business::Role'
  end
end
