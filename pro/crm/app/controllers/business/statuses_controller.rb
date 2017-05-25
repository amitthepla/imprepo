class Business::StatusesController < BusinessController
  def index
    @statuses = @current_org.statuses.asc(:description)
  end

  def show
    @status = @current_org.statuses.find(params[:id])
  end

  def new
    @status = @current_org.statuses.new
  end

  def create
    @statuses = @current_org.statuses.new(status_params)
    if @statuses.save
      redirect_to business_statuses_path
    else
      render :new
    end
  end

  def edit
    @status = @current_org.statuses.find(params[:id])
  end

  def update
    @status = @current_org.statuses.find(params[:id])
    if @status.update(status_params)
      redirect_to @status
    else
      render :edit
    end
  end

  private
   def status_params
    params.require(:business_status).permit(:description,:icon,:color)
   end
end
