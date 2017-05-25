module Business
  class Message
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :organization, class_name: 'Business::Organization'
    belongs_to :contact, class_name: 'Business::Contact'
    belongs_to :lead, class_name: 'Business::Lead', touch: true
    belongs_to :user

    validates_presence_of :body, unless: :ringcentral_provider?

    field :body, type: String, default: nil
    field :type, type: String, default: nil
    field :reply, type: Boolean,  default: false
    field :provider, type: String, default: ''
    field :direction, type: String, default: ''
    field :result, type: String, default: ''
    field :duration, type: Integer, default: 0
    field :call_time, type: Time, default: nil

    def ringcentral_provider?
      self.provider == 'ringcentral'
    end

    def coordinator_messages(id)
      where(user_id: id)
    end

  end
end
