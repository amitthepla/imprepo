module Business
  class Stage
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :organization, class_name: "Business::Organization"

    validates_presence_of :name

    before_save :set_id

    field :name, type: String, default: nil
    field :stage_id, type: String, default: nil
    field :description, type: String, default: nil
    field :type, type: String, default: nil
    field :sort, type: Integer, default: nil
    field :position, type: Integer, default: nil
    field :is_default, type: Boolean, default: false
    field :can_edit, type: Boolean, default: true
    field :roles, type: Array, default: []

    before_validation do |model|
      model.roles.reject!(&:blank?) if model.roles
    end


    STAGE_LIST = Business::Stage.where(type: "lead").map{|stage| stage.name}

    protected

    def set_id
      self.stage_id = self.name.parameterize.underscore
    end
  end
end
