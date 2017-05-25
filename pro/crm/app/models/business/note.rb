module Business
  class Note
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :organization, class_name: 'Business::Organization'
    belongs_to :user
    belongs_to :subject, polymorphic: true

    validates_presence_of :body

    field :body, type: String, default: nil
    field :reply_from, type: String, default: nil
    field :attachment_count, type: Integer, default: 0
  end
end
