module Business
  class Email
    include Mongoid::Document
    include Mongoid::Timestamps

    field :from, type: String
    field :to, type: String
    field :received_at, type: DateTime
    field :subject, type: String
    field :body, type: String
    field :attachment_count, type: Integer, default: 0
  end
end