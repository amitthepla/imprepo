module Business
  class UserTaskSetting
    include Mongoid::Document
    include Mongoid::Timestamps
    
    validates_presence_of :name
    belongs_to :organization, class_name: "Business::Organization"
    belongs_to :user, index: true
    belongs_to :task_setting
    ## If the user creates its own task type
    field :name,        type: String, default: nil      ## Task Name
    field :stage,       type: String, default: nil      ## Lead Stage id
    field :duration,    type: Integer,default: 0        ## Duration in hours when the task will be created automatically
    field :auto_create, type: Boolean,default: false    ## Whether to create the task automatically
    
  end
end