class Marketing::ReportsController < MarketingController

  def index
    @health_check_reports = @current_org.health_check_reports
  end


end
