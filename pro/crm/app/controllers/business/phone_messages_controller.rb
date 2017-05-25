class Business::PhoneMessagesController < BusinessController
  before_action :set_phone_message, only: [:show, :edit, :update, :destroy, :archive_message]
  before_action :not_available
  def index
    @phone_messages = @current_account.phone_messages.where(stage: 'inquiry').desc(:created_at)
    @created_phone_messages = @current_org.phone_messages.where(created_by: @current_account.id)
  end

  def show
    @notes = @phone_message.notes
    @note = @phone_message.notes.new
    @created_by = @current_org.users.find(@phone_message.created_by)
  end

  def new
    @phone_message = @current_org.phone_messages.new
  end

  def create
    @phone_message = @current_org.phone_messages.new(phone_message_params)
    @phone_message.stage = 'inquiry'
    @phone_message.created_by = @current_account._id
    if @phone_message.save
    # 	@created_by = @current_org.users.find(@phone_message.created_by)
		# send_mail({
		# 	:subject=> "Phone Message from #{@created_by.first_name.titleize}",
		# 	:from_name=> "4Beauty CRM",
		# 	:text=>"New phone message",
		# 	:email=> @phone_message.user.email,
		# 	:name=> "4Beauty Team",
		# 	:html=> render_to_string('/mail_templates/new_phone_message', :layout => false, :locals => {:phone_message => @phone_message, :created_by => @created_by }),
		# 	:from_email=>"concierge@4beauty.net"
		# })
      respond_to do |format|
        format.html { redirect_to business_phone_messages_path }
        format.json { render json: { :status => :ok, :message => "Message Created"} }
      end
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @phone_message.update(phone_message_params)
      respond_to do |format|
        format.html { redirect_to business_phone_messages_path }
        format.json { render json: { :status => :ok, :message => "Message Updated"} }
      end
    else
      render :edit
    end
  end

  def mark_complete
    @current_org.phone_messages.find(params[:phone_message_id]).set(stage: 'complete')
    redirect_to business_phone_messages_path
  end

  def destroy
    @phone_message.destroy
    redirect_to business_phone_messages_path, :notice => "Message deleted."
  end

  def archive_message
    @phone_message.set(archived: true)
    redirect_to request.referrer
  end

  private

  def not_available
    redirect_to business_leads_path
  end

  def set_phone_message
    @phone_message = @current_org.phone_messages.find(params[:id])
  end

  def phone_message_params
    params.require(:business_phone_message).permit(:user,:from,:callback_number,:email,:message,:surgery_date,:stage,:created_by)
  end
end
