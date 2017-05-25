module Business
  class Setting
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :organization, class_name: 'Business::Organization'

    field :name, type: String, default: nil
    field :setting_id, type: String, default: nil
    field :data, type: Array, default: nil

    validates_presence_of :name
    before_save :set_id

    protected
    def set_id
      self.setting_id = self.name.parameterize.underscore
    end
  end
end
