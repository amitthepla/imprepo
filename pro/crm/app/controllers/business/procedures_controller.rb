class Business::ProceduresController < BusinessController
  def index
    @procedures = @current_org.procedures.order_by(name: 'asc')
  end

  def show
    @procedure = @current_org.procedures.find(params[:id])
  end

  def new
    @procedure = @current_org.procedures.new
  end

  def create
    @procedure = @current_org.procedures.new(procedure_params)
    if @procedure.save
      redirect_to business_settings_path
    else
      render :new
    end
  end

  def edit
    @procedure = @current_org.procedures.find(params[:id])
  end

  def update
    @procedure = @current_org.procedures.find(params[:id])
    if @procedure.update(procedure_params)
      redirect_to business_settings_path
    else
      render :edit
    end
  end

  private
   def procedure_params
    params.require(:business_procedure).permit(:name, :cost, :slug_value, :details, :procedure_for, :type, :surgical, :medspa)
   end
end
