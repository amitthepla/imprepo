class Business::CastingController < BusinessController
  def index
    @castings = @current_org.castings.asc(:first_name)
  end
end
