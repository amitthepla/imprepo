require 'gmail_client'
class EmailsController < ApplicationController
  include GmailClient
  include EmailHelper
  before_filter :set_up_api, except: [:create, :connect, :logout]
  def mail

    unless request.xhr?
      @labels = @api_client.fetch_labels
    end

    mail_type = params[:mail_type].present? ? params[:mail_type].to_s.upcase : 'INBOX'
    label_id = params[:label_id].present? ? params[:label_id] : 'INBOX'
    begin
      case params[:provider]
        when 'google'
          search_options = {pageToken: params[:page_token].to_s, maxResults: ENV['EMAILS_PER_PAGE'] || 20}
          raw_data, @next_page_token = (params[:q].present?) ? @api_client.search_emails({q: params[:q]}) : @api_client.fetch_emails_by_label(label_id, search_options)
          @emails = raw_data.map { |data| get_basic_info(data) }
        else
          @emails = []
      end      
    rescue Exception => e
      @current_user.email_account.destroy if @current_user.email_account
      redirect_to email_connect_path
    end
    
    if request.xhr?
      case mail_type
        when 'SENT'
          render partial: 'sent', status: :ok
        when 'DRAFT'
          render partial: 'drafts', status: :ok
        when 'TRASH'
          render partial: 'trash', status: :ok
        when 'SPAM'
          render partial: 'trash', status: :ok
        else
          render partial: 'inbox', status: :ok
      end
    end
  end
	def index
		
	end
	def connect
		account = @current_user.email_account
    redirect_to email_mail_path(account.provider) if account.present?
	end
	def create
		success = false
	    if params[:provider] == 'google'
	      success = handle_google_response(request.env['omniauth.auth'], @current_user)
	    end
	    if success
	      redirect_to "/emails"
	    else
	      redirect_to "/emails/connect", alert: 'An error eccoured during processing your request. Please try again.'
	    end
	end

	def handle_google_response(data, user)
	    begin
	      credentials = data['credentials']
	      e_account = EmailAccount.new({
	                                       provider: data['provider'],
	                                       email: data['info']['email'],
	                                       access_token: credentials['token'],
	                                       refresh_token: credentials['refresh_token'],
	                                       expires: credentials['expires'],
	                                       expires_at: credentials['expires_at']
	                                   })
	      e_account.user = user
	      e_account.save!
	    rescue => ex
	      puts "----------------------> Unable to create <----------------------"
	      p ex.message
	      false
	    end
	end

  def show_email
    if params[:provider] == 'google'
      @email = @api_client.get_details(params[:id])
    end
    render partial: 'show_email', status: :ok
  end

  def send_mail
    if params[:provider] == 'google'
      sent = @api_client.send_mail(params)
    end
    #render nothing: true, status: :no_content
    render json: {message: "success"}, status: :ok
  end


  def reply_mail
    begin 
      sent = @api_client.send_mail(params)
      render json: {message: "success"}, status: :ok
    rescue => e
      puts "---------> reply mail error message <---------"
      p e.message
    end
  end

  def toggle_star
    result = @api_client.toggle_star(params[:id], params[:starred] == 'true')
    render json: {result: result}, status: :ok
  end

  def toggle_unread
    result = @api_client.toggle_unread(params[:ids], params[:unread].to_s == 'true')
    render json: {result: result}, status: :ok
  end

  def delete_emails
    result = @api_client.delete_emails(params[:ids])
    render json: {result: result}, status: :ok
  end

  def logout
    @current_user.email_account.destroy if @current_user.email_account
    redirect_to email_connect_path, notice: 'Successfully logged out from email.'
  end

  def failure
    redirect_to email_connect_path
  end	

  private

  def unset_side_panel
    @disable_side_panel = true
  end

  def set_up_api
    account = @current_user.email_account
    redirect_to email_connect_path and return unless account.present?
    account.refresh_access_token! if account.access_token_expired?
    if params[:provider] == 'google'
      @api_client = GmailClient::Gmail.new(account.access_token, account.email)
    else
      redirect_to email_connect_path, notice: 'Email provider is not supported by this application. Please contact the administrator.'
    end
  end
end