class Business::NotesController < BusinessController
  before_action :get_notable
  def index
    @notes = @notable.notes
  end

  def show
    @note = @notable.notes.find(params[:id])
  end

  def new
    @note = @notable.notes.new
  end

  def create
    @lead = @current_org.leads.find(params[:lead_id])
    @note = @notable.notes.new(note_params)
    @note.user_id = @current_account.id
    @note.organization_id = @current_org.id
    if @note.save
      @lead.touch
      redirect_to polymorphic_url([@notable])
    else
      render :new
    end
  end

  def update
  end

  private
   def get_notable
      @subject_type = params[:subject]
      @notable = @current_org.public_send(@subject_type.pluralize).find(params[params[:subject_id]])
   end

   def note_params
    params.require(:business_note).permit(:body)
   end
end
