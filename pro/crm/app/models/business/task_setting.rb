module Business
  class TaskSetting
    include Mongoid::Document
    include Mongoid::Timestamps
    
    validates_presence_of :name, :description, :duration

    belongs_to :organization, class_name: "Business::Organization"
    #belongs_to :stage, class_name: "Business::Stage"
    #before_save :set_id

    field :name,        type: String, default: nil      ## Task Name
    field :description, type: String, default: nil  
    field :stage,       type: String, default: nil      ## Lead Stage
    field :duration,    type: Integer, default: 0        ## Duration in hours when the task will be created automatically
    field :auto_create, type: Boolean, default: false    ## Whether to create the task automatically
    field :auto_email, type: Boolean, default: false 
    protected

    # def set_id
    #   self.setting_id = self.name.parameterize.underscore
    # end
  end
end