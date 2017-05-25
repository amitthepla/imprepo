class Business::StagesController < BusinessController
  before_action :set_task_stage, only: [:destroy]
  def index
    @stages = @current_org.stages
    @lead_stages = @stages.where(type: 'lead').asc(:position)
    @deal_stages = @stages.where(type: 'deal').asc(:position)
    @task_stages = @stages.where(type: 'task').asc(:position)
  end

  def new
    @stage = @current_org.stages.new
  end

  def show
    @stage = @current_org.stages.find(params[:id])
  end
def edit
  @stage = @current_org.stages.find(params[:id])
end

  def create
    @stage = @current_org.stages.new(stage_params)
    if @stage.save
      redirect_to business_stages_path(anchor: @stage.type.pluralize)
    else
      render :new
    end
  end

  def update
    @stage = @current_org.stages.find(params[:id])
    if @stage.update(stage_params)
      respond_to do |format|
        format.html { redirect_to business_stages_path(anchor: @stage.type.pluralize) }
        format.json { render json: { :status => :ok, :message => "Stage Updated"} }
      end
    else
      render :edit
    end
  end

  def destroy
    @task_stage.destroy
    redirect_to business_stages_path, :notice => "Stage deleted."

  end

  private

  def set_task_stage
    @task_stage = @current_org.stages.find(params[:id])
  end

   def stage_params
    params.require(:business_stage).permit(:name,:description,:type,:position,{:roles => []})
   end
end
