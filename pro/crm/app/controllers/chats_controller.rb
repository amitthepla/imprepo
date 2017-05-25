require 'securerandom'
class ChatsController < ApplicationController
  include ChatsHelper
  layout false

  before_filter :reset_recent_activity, only: [:chat_history, :reset_last_chat_activity]

  def chat_panel
    @collection = @current_org.users.order_by({first_name: :asc}).reject { |u| u.id == current_user.id }.map { |u| u.to_listing(@current_account.id.to_s)}
    render partial: 'shared/chat'
  end

  # POST /channel
  # Create a new channel for reuse the existing channel for a conversation.
  # @author Sambit Mohanty <smbmohanty@gmail.com>
  def create_channel
    from = @current_account.id.to_s
    receiver = params[:to]
    condition = {'$or' => [{sender: from, receiver_id: params[:to]}, {sender: params[:to], receiver_id: from}]}
    conversation = Conversation.where(condition).order_by(created_at: 'ASC').last
    if conversation && (conversation.archived_users & [from, params[:to]]).count != 2
      if conversation.archived_users.include?(from)
        conversation.archived_users.delete(from)
        conversation.save!
      end
      channel_id = conversation.channel
    else
      channel_id = SecureRandom.uuid
      new_conversation = Conversation.new({sender: from, channel: channel_id})
      if params[:type] == 'group'
        members = params[:members].split(',')
        user_activities = {}
        members.each do |member|
          user_activities[member] = Time.now.utc
        end
        new_conversation.user_activities = user_activities
        conversation_group = ConversationGroup.new({members: members})
        conversation_group.created_by = @current_account
        conversation_group.save!
        new_conversation.receiver = conversation_group
        new_conversation.save!
        receiver = conversation_group.id.to_s
      elsif params[:type] == 'individual'
        user_activities = {"#{from}" => Time.now.utc, "#{receiver}" => Time.now.utc}
        new_conversation.user_activities = user_activities
        new_conversation.receiver = User.find(params[:to])
        new_conversation.save!
      else
        # Handle error
        render json: {channel: nil}, status: :not_acceptable and return
      end
    end
    # Handle success
    render json: {channel: channel_id, receiver: receiver}, status: :ok
  end

  # GET /chat_history
  # Fetch all the conversation made by given channel and user id.
  # @author Sambit Mohanty <smbmohanty@gmail.com>
  def chat_history
    if @conversation
      last_deleted = @conversation.conversation_replies.where({archived_by: params[:user_id].to_s}).order_by(created_at: 'ASC').last
      if last_deleted
        conversation_replies = @conversation.conversation_replies.where({created_at: {'$gt' => last_deleted.created_at}}).order_by(created_at: 'ASC')
      else
        conversation_replies = @conversation.conversation_replies.order_by(created_at: 'ASC')
      end
      render json: {data: conversation_replies.map { |cr| cr.to_listing }}, status: :ok
    else
      render json: {data: []}, status: :ok
    end
  end

  def conversation_members
    if params[:cnv_type] == 'individual'
      @collection = @current_org.users.order_by({first_name: :asc}).reject { |u| u.id == current_user.id }.map { |u| u.to_listing(@current_account.id.to_s)}
    elsif params[:cnv_type] == 'group'
      @collection = group_conversations(@current_account.id.to_s).sort_by{|group| group[:name]}.map { |gc| gc.to_listing(@current_account.id.to_s)}
    elsif params[:cnv_type] == 'recent'
      @collection = {}
    end
    render partial: 'shared/chat_member'
  end

  def get_group_members
    @conversation_group = ConversationGroup.find(params[:id])
    @collection = User.find(@conversation_group.members)
    render partial: 'shared/group_members'
  end

  def update_group_name
    conversation_group = ConversationGroup.find(params[:gid])
    conversation_group.name = params[:name]
    render json: {success: conversation_group.save}, status: :ok
  end

  def upload_attachment
    begin
      cnv_upload = ConversationUpload.create({attachment: params[:attachment]})
      render json: {id: cnv_upload.id.to_s, url: cnv_upload.attachment.url}, status: :ok
    rescue => ex
      p ex.message
      render json: {}, status: :internal_server_error
    end
  end

  def reset_last_chat_activity
    render nothing: true, status: :no_content
  end

  private

  def reset_recent_activity
    @conversation = Conversation.where({channel: params[:channel_id]}).first
    @conversation.user_activities[@current_account.id.to_s] = Time.now.utc
    @conversation.save
  end
  
end
