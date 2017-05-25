class ConversationReply
  include Mongoid::Document
  include Mongoid::Timestamps

  field :conversation_id, type: String
  field :sender, type: String
  field :receiver, type: String
  field :message, type: String
  field :archived_by, type: String, default: nil

  belongs_to :conversation
  has_one :conversation_upload, dependent: :destroy

  validates_presence_of :conversation_id, :sender, :receiver

  scope :unread_messages, ->(from_date, user_id) {where({created_at: {'$gt' => from_date}, sender: {'$ne' => user_id}})}

  def to_listing
    attachment = self.conversation_upload
    {
        message_id: _id.to_s,
        message: message,
        timestamp: created_at.in_time_zone('Eastern Time (US & Canada)').strftime('%b %d, %Y %H:%M'),
        sender: sender,
        receiver: receiver,
        attachment_name: attachment.present? ? attachment.attachment_file_name : '',
        attachment_type: attachment.present? ? attachment.attachment_content_type : ''
    }
  end
end
