class Business::DealsController < BusinessController
  before_action :set_deal, only: [:show, :edit, :update]
  def index
    @deals = @current_org.deals
    @stages = @current_org.stages.where(type: 'deal').asc(:position)
    @qualified_leads_stage = @current_org.stages.where(type: 'lead').desc(:position).first
    @qualified_leads = @current_org.leads.where(stage: @qualified_leads_stage.stage_id) if @qualified_leads_stage.present?
  end

  def show
    @notes = @deal.notes
    @note = @deal.notes.new
  end

  def new
    @deal = @current_org.deals.new
  end

  def create
    @deal = @current_org.deals.new(deal_params)
    if @deal.save
      redirect_to @deal
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @deal.update(lead_params)
      redirect_to @deal
    else
      render :edit
    end
  end

  private

  def set_deal
    @deal = @current_org.deals.find(params[:id])
  end

  def deal_params
    params.require(:business_deal).permit(:source)
  end
end