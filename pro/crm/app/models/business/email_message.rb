module Business
  class EmailMessage
    include Mongoid::Document
    include Mongoid::Timestamps

    validates_presence_of :name
    validates_presence_of :message

    belongs_to :organization, class_name: "Business::Organization"

    before_save :set_id

    field :name, type: String, default: nil
    field :message_id, type: String, default: nil
    field :message, type: String, default: nil
    field :visible, type: Boolean, default: true
    field :order, type: Integer, default: nil


    def self.visible_from_show
      where(visible: true)
    end

    protected

    def set_id
      self.message_id = self.name.parameterize.underscore
    end
  end
end
