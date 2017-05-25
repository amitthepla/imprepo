class Business::HealthCheckReportsController < BusinessController
  before_action :set_report, only: [:show, :destroy]
  layout 'public'
  def index
    @health_check_reports = @current_org.health_check_reports
    respond_to do |format|
      format.js
    end
  end

  def show
    @report.update_attributes(viewed: true)
    respond_to do |format|
      format.html
      format.pdf {render :pdf => 'show', :header => {:font_size => '10'}}
    end
  end

  def new
    HealthCheckReportWorker.perform_async(@current_org.id, @current_user.id)
  end


  def destroy
    @report_id = @report.id
    @report.destroy
  end

  private

  def set_report
    @report = @current_org.health_check_reports.find(params[:id])
  end
end
