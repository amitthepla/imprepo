class Business::SurgeriesController < ApplicationController
  before_action :set_business_surgery, only: [:show, :edit, :update, :destroy]
  layout "business"

  # GET /business/surgeries
  # GET /business/surgeries.json
  def index
    if params[:status].present?
      @status = params["status"]
    else
      @status = "scheduled"
    end

    if !params[:start_date].present? && !params[:end_date].present?
      params[:start_date] =  Date.today.beginning_of_month.beginning_of_day.strftime('%m/%d/%Y')
      params[:end_date] = Date.today.end_of_month.end_of_day.strftime('%m/%d/%Y')
    end

    start =  Date.strptime(params[:start_date], '%m/%d/%Y')
    ending = Date.strptime(params[:end_date], '%m/%d/%Y')

    if is_admin?(@current_account)
      surgery_pool = @current_org.surgeries
    else
      surgery_pool = @current_account.surgeries
    end

    if @status != "scheduled"
      @surgeries = surgery_pool.date_range(start, ending).where(@status.to_sym => true)
    else
      @surgeries = surgery_pool.date_range(start, ending).where(:completed => false, :cancelled => false)
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /business/surgeries/1
  # GET /business/surgeries/1.json
  def show
  end

  def book
    @lead = @current_org.leads.find(params[:lead_id])
    @surgery = Business::Surgery.new()
    roles = Business::Role.where(:name.in => ["Surgeon", "Physician Assistant"]).collect(&:id).map(&:to_s)
    @physicians = @current_org.users.where(:roles.in => roles)
    respond_to do |format|
      format.js
    end
  end

  # GET /business/surgeries/1/edit
  def edit
  end

  # POST /business/surgeries
  # POST /business/surgeries.json
  def create
    @surgery = Business::Surgery.new(business_surgery_params)
    @lead = @surgery.lead
    respond_to do |format|
      if @surgery.save
        @surgery.lead.update_attribute(:stage, 'booked_surgery')
        format.js { render :file => "app/views/business/surgeries/surgery.js.erb" }
      else
        @surgery_errors = @surgery.errors.full_messages.map(&:inspect).join(', ').gsub!('"', '').humanize if @surgery.errors.any?
        format.js { render :file => "app/views/business/surgeries/surgical_error.js.erb" }
      end
    end
  end

  # PATCH/PUT /business/surgeries/1
  # PATCH/PUT /business/surgeries/1.json
  def update
    @surgery.update(business_surgery_params)
    @lead = @surgery.lead
    respond_to do |format|
      if  @surgery.save
        @lead.update_attribute(:stage, 'booked_surgery')
        format.js { render :file => "app/views/business/surgeries/surgery.js.erb" }
      else
        @surgery_errors = @surgery.errors.full_messages.map(&:inspect).join(', ').gsub!('"', '').humanize if @surgery.errors.any?
        format.js { render :file => "app/views/business/surgeries/surgical_error.js.erb" }
      end
    end
  end

  # DELETE /business/surgeries/1
  # DELETE /business/surgeries/1.json
  def destroy
    @surgery.destroy
    respond_to do |format|
      format.html { redirect_to business_surgeries_url, notice: 'Surgery was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_business_surgery
      @surgery = Business::Surgery.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def business_surgery_params
      params.require(:business_surgery).permit(:cost, :date, :completed, :cancelled, :procedure, :lead_id, :physician_id)
    end
end
