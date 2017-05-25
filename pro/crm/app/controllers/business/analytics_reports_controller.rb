class Business::AnalyticsReportsController < BusinessController
  before_action :set_report, only: [:show, :destroy]
  layout 'public'
  def index
    @analytics_reports = @current_org.analytics_reports
    respond_to do |format|
      format.js
    end
  end

  def show
    @report.update_attributes(viewed: true)
    respond_to do |format|
      format.html
    end
  end

  def new
    date_hash = {
      start: params[:start_date],
      end: params[:end_date]
    }
    AnalyticsReportWorker.perform_async(@current_org.id, @current_user.id, date_hash, params[:analytics_type])
  end


  def destroy
    @report_id = @report.id
    @report.destroy
  end

  private

  def set_report
    @report = @current_org.analytics_reports.find(params[:id])
  end
end
