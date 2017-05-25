class Marketing::OrganizationsController < MarketingController
  def index
    @orgs = [@current_org]
  end

  def show
    @org = Business::Organization.find(params[:id])
    @org_owner = @org.users.find(@org.owner_id)
  end

  def new
    @org = Business::Organization.new
  end

  def update
  end
end