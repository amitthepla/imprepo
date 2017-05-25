require 'gmail_client'
class Business::EmailsController < BusinessController
  include GmailClient
  include Business::EmailHelper
  before_action :set_up_api, except: [:connect, :logout]
  layout 'emails', except: [:connect, :logout]

  def mail

    unless request.xhr?
      @labels = @api_client.fetch_labels
    end

    mail_type = params[:mail_type].present? ? params[:mail_type].to_s.upcase : 'INBOX'
    label_id = params[:label_id].present? ? params[:label_id] : 'INBOX'
    case params[:provider]
      when 'outlook'
        search_options = {pageToken: params[:page_token].present? ? params[:page_token] : 0}
        @messages, @next_page_token = (params[:q].present?) ? @api_client.search_emails({q: params[:q]}) : @api_client.fetch_emails_by_label(label_id, search_options)
        @emails = @messages.map { |data| Business::EmailHelper::Outlook::get_outlook_info(data) }
      when 'google'
        search_options = {pageToken: params[:page_token].to_s, maxResults: ENV['EMAILS_PER_PAGE'] || 20}
        raw_data, @next_page_token = (params[:q].present?) ? @api_client.search_emails({q: params[:q]}) : @api_client.fetch_emails_by_label(label_id, search_options)
        @emails = raw_data.map { |data| get_basic_info(data) }
      else
        @emails = []
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

  def connect
    account = @current_account.email_account
    redirect_to business_email_mail_path(account.provider) if account.present?
  end

  def show_email
    if params[:provider] == 'outlook'
      @email = @api_client.get_outlook_details(params[:id])
    else
      @email = @api_client.get_details(params[:id])
    end
    render partial: 'show_email', status: :ok
  end

  def send_mail
    if params[:provider] == 'outlook'
      sent = @api_client.send_outlook_mail(params)
    else
      sent = @api_client.send_mail(params)
    end
    #render nothing: true, status: :no_content
    render json: {message: "success"}, status: :ok
  end


  def reply_mail
    begin 
      #{"utf8"=>"â", "reply_to_email"=>"Amit Mohanty <mohanty.amit888@gmail.com>", "reply_to_subject"=>"Hey test", "reply_to_message_id"=>"<CAG_trFgwyPzWDpH+0g1HO9Tf9YawGOhvE4Wk6=ps=Qcea0Z37g@mail.gmail.com>", "is_reply_message"=>"true", "to"=>"Amit Mohanty <mohanty.amit888@gmail.com>", "subject"=>"Re: Hey test", "body"=>"test vdfgdfg", "commit"=>"Send", "controller"=>"business/emails", "action"=>"reply_mail", "provider"=>"google"}
      sent = @api_client.send_mail(params)
      render json: {message: "success"}, status: :ok
    rescue => e
      puts "---------> "
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
    @current_account.email_account.destroy if @current_account.email_account
    redirect_to business_email_connect_path, notice: 'Successfully logged out from email.'
  end

  private

  def unset_side_panel
    @disable_side_panel = true
  end

  def set_up_api
    account = @current_account.email_account
    redirect_to business_email_connect_path and return unless account.present?
    account.refresh_access_token! if account.access_token_expired?
    if params[:provider] == 'outlook'
      @api_client = OutlookClient::Outlook.new(account.access_token, account.email)
    elsif params[:provider] == 'google'
      @api_client = GmailClient::Gmail.new(account.access_token, account.email)
    else
      redirect_to business_email_connect_path, notice: 'Email provider is not supported by this application. Please contact the administrator.'
    end
  end

end
