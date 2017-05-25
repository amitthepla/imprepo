module Business
  class Activity
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :subject, polymorphic: true

    validates_presence_of :body

    field :body, type: String, default: nil
  end
end