class Business::DiagnosticReportsController < BusinessController
  before_action :set_report, only: [:show, :destroy]
  layout 'public'
  def index
    @diagnostic_reports = @current_org.diagnostic_reports
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
      first_start: params[:first_start_date],
      first_end: params[:first_end_date],
      second_start: params[:second_start_date],
      second_end: params[:second_end_date]
    }
    
    DiagnosticReportWorker.perform_async(@current_org.id, @current_user.id, date_hash)
  end


  def destroy
    @report_id = @report.id
    @report.destroy
  end

  private

  def set_report
    @report = @current_org.diagnostic_reports.find(params[:id])
  end
end
