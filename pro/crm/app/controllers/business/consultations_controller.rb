class Business::ConsultationsController < BusinessController
  before_action :set_consultation, only: [:show, :edit, :update, :destroy]

  # GET /consultations
  # GET /consultations.json
  def index
    if params[:status].present?
      @status = params["status"]
    else
      @status = "scheduled"
    end

    if !params[:start_date].present? && !params[:end_date].present?
      params[:start_date] =  Date.today.beginning_of_month.strftime('%m/%d/%Y')
      params[:end_date] = Date.today.end_of_month.strftime('%m/%d/%Y')
    end

    start =  Date.strptime(params[:start_date], '%m/%d/%Y')
    ending = Date.strptime(params[:end_date], '%m/%d/%Y')

    if is_admin?(@current_account)
      consult_pool = @current_org.consultations
    else
      consult_pool = @current_account.consultations
    end

    if @status != "scheduled"
      @consultations = consult_pool.date_range(start, ending).where(@status.to_sym => true)
    else
      @consultations =  consult_pool.date_range(start, ending).where(:booked => false, :cancelled => false, :no_show => false)
    end

    respond_to do |format|
      format.html
      format.js
    end

  end

  # GET /consultations/1
  # GET /consultations/1.json
  def show
  end


  def book
    @lead = @current_org.leads.find(params[:lead_id])
    @consultation = Business::Consultation.new()
    roles = Business::Role.where(:name.in => ["Surgeon", "Physician Assistant"]).collect(&:id).map(&:to_s)
    @physicians = @current_org.users.where(:roles.in => roles)
    respond_to do |format|
      format.js
    end
  end

  # GET /consultations/1/edit
  def edit
  end

  # POST /consultations
  # POST /consultations.json
  def create
    @consultation = Business::Consultation.new(consultation_params)
    @lead = @consultation.lead
    respond_to do |format|
      if @consultation.save
        @consultation.lead.update_attribute(:stage, 'booked_consult')
        @consultation.lead.save
        format.js { render :file => "app/views/business/consultations/consult.js.erb" }
      else
        @consult_errors = @consultation.errors.full_messages.map(&:inspect).join(', ').gsub!('"', '').humanize if @consultation.errors.any?
        format.js { render :file => "app/views/business/consultations/consult_error.js.erb" }
      end
    end
  end

  # PATCH/PUT /consultations/1
  # PATCH/PUT /consultations/1.json
  def update
    @lead = @consultation.lead
    respond_to do |format|
      if @consultation.update(consultation_params)
        @consultation.lead.update_attribute(:stage, 'booked_consult')
        @consultation.lead.save
        format.js { render :file => "app/views/business/consultations/consult.js.erb" }
      else
        @consult_errors = @consultation.errors.full_messages.map(&:inspect).join(', ').gsub!('"', '').humanize if @consultation.errors.any?
        format.js { render :file => "app/views/business/consultations/consult_error.js.erb" }
      end
    end
  end

  # DELETE /consultations/1
  # DELETE /consultations/1.json
  def destroy
    @consultation.destroy
    respond_to do |format|
      format.html { redirect_to consultations_url, notice: 'Consultation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_consultation
      @consultation = Business::Consultation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def consultation_params
      params.require(:business_consultation).permit(:lead_id, :date, :cancelled, :no_show, :cost, :physician_id)
    end
end
