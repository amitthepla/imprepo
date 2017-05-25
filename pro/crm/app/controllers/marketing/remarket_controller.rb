require 'mailchimp_client'
class Marketing::RemarketController < MarketingController
  include MailchimpClient

  #this  page will generate the list of users that will recevie the direct text message marketing
  def new
    sales = @current_org.roles.where({name: 'Sales Coordinator'}).first
    sales_users = sales.present? ? @current_org.users.where({roles: sales.id.to_s}) : []
    @coordinators = sales_users
    @stages = @current_org.stages.where(type: 'lead')
    @mailchimp = MailchimpClient::Mailchimp.new((@current_org.mailchimp_account.api_key rescue ''))
  end

  def index
    sales = @current_org.roles.where({name: 'Sales Coordinator'}).first
    sales_users = sales.present? ? @current_org.users.where({roles: sales.id.to_s}) : []
    @coordinators = sales_users
    @leads = @current_org.leads.search(params[:search]).date_range(params[:start_date], params[:end_date]).stage_selection(params[:stage]).coordinator_search(params[:coordinator]).where(:phone.ne => nil)
    @stages = @current_org.stages.where(type: 'lead')
    @mailchimp = MailchimpClient::Mailchimp.new((@current_org.mailchimp_account.api_key rescue ''))
  end

  def send_mass_text
    leads = params[:leads].split(" ")
    options = {
        org_id: @current_org.id.to_s,
        leads: leads,
        body: params[:message],
        media_url: params[:media_url]
    }
    MassTextWorker.perform_in(1.minute, options)
    redirect_to remarket_path, notice: 'Request has been submitted successfully and will be processed soon.'

  end

  def send_mass_email
    options = {
        api_key: (@current_org.mailchimp_account.api_key rescue ''),
        list_id: params[:list],
        campaign_id: params[:campaign],
        org_id: @current_org.id.to_s,
        search: params[:search],
        start_date: params[:start_date],
        end_date: params[:end_date],
        stage: params[:stage],
        coordinator: params[:coordinator]
    }
    MailchimpClient::Mailchimp.new((@current_org.mailchimp_account.api_key rescue '')).update_campaign_list(params[:campaign], params[:list])
    AddSubscribersWorker.perform_async(options)
    redirect_to remarket_path, notice: 'Request has been submitted successfully and will be processed soon.'
  end

  def create_list
    mailchimp = MailchimpClient::Mailchimp.new((@current_org.mailchimp_account.api_key rescue ''))
    list_status = mailchimp.create_list(params)
    if list_status
      render json: {list_id: list_status['id'], list_name: list_status['name']}, status: :ok
    else
      render json: {}, status: :internal_server_error
    end
  end

end
