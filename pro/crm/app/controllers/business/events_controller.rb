class Business::EventsController < BusinessController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  def index
    ##commented for now the stages are set for user not for the role
    #@stages =  @current_org.stages.where(type: 'lead',roles: "#{@current_account.role.id}").asc(:position)

    #@events = @current_org.events.asc(:start_time)
    @stages =  Business::Stage.where(:id.in=>@current_account.stages,:type=>"lead") #  @current_org.stages.where(type: 'lead',roles: "#{@current_account.role.id}").asc(:position)

  end

  def show
  end

  def new
    @event = @current_org.events.new
  end

  def create
    @contact = Business::Contact.find(params[:business_event][:contact])
    @contact.set(external_record_id: params[:external_record_id]) if !params[:external_record_id].empty?
    @event = @current_org.events.new(event_params)
    @event.start_time = DateTime.parse("#{params[:user_date]}T#{params[:user_start_time]}+00:00")
    @event.end_time = DateTime.parse("#{params[:user_date]}T#{params[:user_end_time]}+00:00")
    @event.user = @current_account
    if @event.save
      @lead = @contact.leads.last
      @lead.set(:stage => 'booked_consult')
      @lead.push(stage_lifecycle: { :stage => 'booked_consult', :timestamp => Time.now })
      if params[:send_forms]
        @mail = send_mail({
          :subject=> "Your consultation forms",
          :from_name=> @contact.account_rep.full_name,
          :text=>"Thank you for contacting the offices of Dr. Mendieta",
          :email=> @contact.email,
          :name=> "#{@contact.first_name} #{@contact.last_name}",
          :html=> render_to_string('/mail_templates/consultation_forms', :layout => false, :locals => {:first_name => @contact.first_name, :consultation_id => @contact.public_token}),
          :from_email=>"concierge@4beauty.net"
        })
        @lead.activities.create(body: "Consultation Forms e-mail was sent.")
        @lead.notes.create(body: "Consultation Forms e-mail was sent.")
      end
      redirect_to business_contact_path(@contact)
    else
      render :new
    end
  end

  def search
   @events = []
   stages =  Business::Stage.where(:id.in=>@current_account.stages,:type=>"lead") #  @current_org.stages.where(type: 'lead',roles: "#{@current_account.role.id}").asc(:position)
   ##commented for now the stages are set for user not for the role
   #stages = @current_org.stages.where(type: 'lead',roles: "#{@current_account.role.id}").map(&:stage_id)
   all_events = @current_org.events(:start_time.gte => Date.parse(params[:start]),:start_time.lte => Date.parse(params[:end]).end_of_day)
   if(@current_account.is_public? == false)
    all_events = all_events.where(:user_id=>@current_account.id)
   end
    if(params[:type].present? && params[:type] != 'All' )
      all_events.map{|eve| @events << eve if eve.contact.leads.last.stage == params[:type] }
    else
      all_events.map{|eve| @events << eve if stages.include? eve.contact.leads.last.stage }
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to @event
    else
      render :edit
    end
  end

  def destroy
    @event.destroy
    redirect_to business_events_path, :notice => "Event deleted."
  end

  private

  def set_event
    @event = @current_org.events.find(params[:id])
  end

  def event_params
    params.require(:business_event).permit(:contact,:description,:start_time,:end_time,:status,:type,:location,{:resources => []})
  end
end