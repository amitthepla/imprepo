class Business::EmailMessagesController < BusinessController
  before_action :get_message , only: [:show,:edit,:update,:destroy, :send_message]
  def index
    @email_messages = @current_org.email_messages
    respond_to do |format|
      format.js { render layout: false, content_type: 'text/javascript' }
    end
  end

  def edit
    respond_to do |format|
      format.js { render layout: false, content_type: 'text/javascript' }
    end
  end

  def show
    respond_to do |format|
      format.js { render layout: false, content_type: 'text/javascript' }
    end
  end

  def new
    @new_message = @current_org.email_messages.new()
    respond_to do |format|
      format.js { render layout: false, content_type: 'text/javascript' }
    end
  end

  def create
    @email_message = @current_org.email_messages.new(message_params)
    if @email_message.save
      @email_messages = @current_org.email_messages
      respond_to do |format|
        format.js { render layout: false, content_type: 'text/javascript' }
      end
    else
      @email_message_errors = @email_message.errors.full_messages.map(&:inspect).join(', ').gsub!('"', '').humanize if @email_message.errors.any?
      respond_to do |format|
        format.js { render :file => "app/views/business/email_messages/save_error.js.erb" }
      end
    end
  end

  def update
    respond_to do |format|
      if @email_message.update(message_params)
        @email_messages = @current_org.email_messages
        format.js { render :file => "app/views/business/email_messages/update.js.erb" }
      else
        @email_message_errors = @email_message.errors.full_messages.map(&:inspect).join(', ').gsub!('"', '').humanize if @email_message.errors.any?
        format.js { render :file => "app/views/business/email_messages/email_message_error.js.erb" }
      end
    end
  end

  def destroy
    @email_message.delete
    @email_messages = @current_org.reload.email_messages
    respond_to do |format|
      format.js { render layout: false, content_type: 'text/javascript' }
    end
  end

  def send_message
    @lead = @current_org.leads.find(params[:lead_id])
    begin
      send_mail({
                    :subject => @email_message.name.titleize,
                    :from_name => @lead.user.full_name,
                    :email => @lead.email,
                    :html => render_to_string('/mail_templates/general', :layout => false, :locals => {:first_name => @lead.first_name.titleize, :lead_id => @lead._id, :user => @lead.user.first_name.titleize, message_id: @email_message.id}),
                    :from_email => @lead.user.email
                })
      @status = true
      @lead.notes.create(body: @email_message.message)
      @lead.activities.create(body: "#{@current_user.full_name} sent #{@email_message.name} to #{@lead.name}")
      @lead.contact.messages.create(body: @email_message.message, user: @current_user, lead: @lead, organization: @current_org, type: 'email')
    rescue Exception => @ex
      @status = false
    end
    respond_to do |format|
      format.js { render layout: false, content_type: 'text/javascript' }
    end
  end

  private
   def get_message
     @email_message = @current_org.email_messages.find(params[:id])
   end

   def message_params
    params.require(:business_email_message).permit(:name,:message,:message_id)
   end
end
