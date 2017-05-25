class Marketing::LogController < MarketingController
  helper_method :sort_column, :sort_direction

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


  private

  def sort_column
   Business::Lead.where(organization: @current_org).where(:consultation_date.nin => [nil]).column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
   %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end


end
