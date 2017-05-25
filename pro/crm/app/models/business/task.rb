module Business
  class Task
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :organization, class_name: "Business::Organization", index: true
    belongs_to :lead, class_name: "Business::Lead", index: true
    belongs_to :user, index: true
    belongs_to :subject, polymorphic: true

    has_many :notes, as: :subject, dependent: :destroy, class_name: "Business::Note"

    validates_presence_of :due_date, :communication

    field :title, type: String, default: nil
    field :description, type: String, default: nil
    field :due_date, type: DateTime, default: nil
    field :created_by, type: BSON::ObjectId, default: nil
    field :priority, type: String, default: nil
    field :stage, type: String, default: nil
    field :completed_by, type: BSON::ObjectId, default: nil
    field :communication, type: String, default: "Call"

    COMMUNICATION_METHODS = ["Call", "Email", "Text"]

    def self.incomplete_tasks
      where(stage: 'inquiry')
    end


    def start_time
      self.due_date
    end

    def self.due_date_search(start_date, end_date)
      if start_date == "" || end_date == "" || start_date == nil || end_date == nil
        scoped
        # where(:due_date.gte => Date.today.beginning_of_day,
        #       :due_date.lte => Date.today.end_of_day)
      else
        starting_date = Date.strptime(start_date, '%m/%d/%Y')
        ending_date = Date.strptime(end_date, '%m/%d/%Y')
        where(:due_date.gte => starting_date.beginning_of_day,
              :due_date.lte => ending_date.end_of_day)
      end
    end

    def self.due_date_today(today)
      if !today.present?
        scoped
      else

        where(:due_date.gte => Date.today.beginning_of_day,
              :due_date.lte => Date.today.end_of_day)
      end
    end

    def self.due_date_old(old)
      if !old.present?
        scoped
      else
        where(:due_date.lt => Date.today.beginning_of_day)
      end
    end

  end
end
