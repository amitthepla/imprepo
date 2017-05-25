class ConversationGroup
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String, :default => 'New Message'
  field :members, type: Array, :default => []

  has_one :conversation, as: :receiver
  belongs_to :created_by, class_name: 'User'

  def to_listing(user_id)
    conversation = self.conversation
    unread_count = (conversation.present? && conversation.user_activities[user_id].present?) ? conversation.conversation_replies.unread_messages(conversation.user_activities[user_id], user_id).count : 0
    {
        id: id.to_s,
        channel: conversation.channel,
        name: name,
        unread: unread_count,
        type: 'group',
    }
  end

end
