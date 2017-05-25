require 'ringcentral_client'
class Business::DashboardController < BusinessController
  include Business::DashboardHelper

  def analytics_data
    @path = "#{Rails.root}/app/helpers/dashboard_json/"
    if File.exist?("#{@path}#{params[:file]}.json")
      json_data = File.read("#{@path}#{params[:file]}.json")
    elsif params[:file] == 'revenue_by_month' && File.exist?("#{@path}income.json")
      json_data = File.read("#{@path}income.json")
    else
      json_data = ''
    end

    case params[:file]
      when 'income', 'revenue_by_month'
        json_data = revenue_by_month(JSON.parse(json_data))
      when 'revenue_by_coordinator'
        json_data = revenue_by_coordinator
      when 'qualified_leads_per_month'
        json_data = qualified_leads_per_month
      when 'new_leads_per_month'
        json_data = new_leads_per_month(JSON.parse(json_data))
      when 'closing_rate_by_practice_by_month'
        json_data = closing_rate_by_practice_by_month
      when 'closing_rate_by_cooardinator_by_month'
        json_data = closing_rate_by_cooardinator_by_month
      else
    end
    render :json => json_data
  end

  def ping
    render :text => 'pong'
  end

  def calendar
    date = !params[:start_date].nil? ? params[:start_date].to_date : Date.today
    @consults = @current_org.consultations.where({:date => {'$gte' => date.at_beginning_of_month, '$lte' => date.at_end_of_month }})
    @procedures = @current_org.surgeries.where({:date => {'$gte' => date.at_beginning_of_month, '$lte' => date.at_end_of_month}})
    @events = @consults + @procedures
    respond_to do |format|
      format.html
      format.js { render :file => "app/views/business/dashboard/month_calendar.js.erb" }
    end

  end
end
