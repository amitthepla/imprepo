class Conversation
  include Mongoid::Document
  include Mongoid::Timestamps

  field :channel,         type: String
  field :sender,          type: String
  field :receiver_id,     type: String
  field :receiver_type,   type: String
  field :archived_users,  type: Array, default: []
  field :user_activities, type: Hash, default: {}

  belongs_to :receiver, polymorphic: true
  has_many :conversation_replies, dependent: :destroy

  validates_presence_of :channel, :sender, :receiver

end
