require File.expand_path('../../../config/environment', __FILE__)

module ChatsHelper

  def save_chat_history(channel, sender, message, receiver, att_id)
    begin
      return nil unless channel && sender && message && receiver
      conversation = Conversation.where({channel: channel}).first
      return nil unless conversation.present?
      conversation_reply = ConversationReply.new(sender: sender, receiver: receiver, message: message)
      conversation_reply.conversation = conversation
      conversation_reply.save

      if att_id.present?
        cnv_upload = ConversationUpload.find(att_id)
        cnv_upload.conversation_reply = conversation_reply
        cnv_upload.save
      end

      conversation_reply.created_at.in_time_zone('Eastern Time (US & Canada)').strftime('%b %d, %Y %H:%M')
    rescue => ex
      p ex.message
      nil
    end
  end

  def get_attachment_details(att_id)
    begin
      att = ConversationUpload.find(att_id)
      return att.attachment_file_name, att.attachment_content_type
    rescue => ex
      p ex
      return '', ''
    end
  end

  # Undo archive a conversation by channel id for a given user.
  #   The user will be able to view the conversation list on their chat dashboard.
  #
  # @param [String] user_id Id of the user to be archived
  # @param [String] channel_id Id of channel for which the user will be archived
  # @return [Boolean] Status
  def unarchive(user_id, channel_id, type)
    begin
      conversation = Conversation.where({channel: channel_id}).first
      if type == 'individual'
        conversation.archived_users.delete(user_id.to_s)
      else
        conversation.archived_users = []
      end
      conversation.save!
    rescue => ex
      p ex.message
      false
    end
  end

  # Archives a conversation by channel id for a given user.
  #   The user will not able to view the conversation list on their chat dashboard once archived.
  #
  # @param [String] user_id Id of the user to be archived
  # @param [String] channel_id Id of channel for which the user will be archived
  # @return [Boolean] Status
  def archive(user_id, channel_id)
    begin
      conversation = Conversation.where({channel: channel_id}).first
      conversation.archived_users << user_id
      if conversation.save
        # Make entry in +ConversationReply+ table.
        make_blank_entry(conversation)
      else
        false
      end
    rescue
      false
    end
  end

  # Get list of group conversations by user
  # @param user_id [String] The user id to fetch conversations
  # @return [Array] Containing the list of conversations
  def group_conversations(user_id)
    (ConversationGroup.where(members: user_id) | ConversationGroup.where(created_by: user_id))
  end

  private

  # Make an entry in +ConversationReply+ table to restrict older histories.
  # @param [Conversation] conversation
  # @param [String] user_id
  def make_blank_entry(conversation, user_id = nil)
    if user_id
      conversation.conversation_replies.create({sender: 'anonymous', receiver: 'anonymous', archived_by: user_id})
    else
      conversation.conversation_replies.create({sender: 'anonymous', receiver: 'anonymous', archived_by: conversation.archived_users.last})
    end
  end
end
