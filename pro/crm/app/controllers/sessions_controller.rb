class SessionsController < BusinessController
  include SessionsHelper

  def create
    success = false
    if params[:provider] == 'outlook'
      redirect_to business_email_connect_path(message: params[:error]) and return if params[:error].present?
      data = nil
      if (code = params[:code]).present?
        data = SessionsHelper::Outlook::get_token_from_code(code)
      end
      success = SessionsHelper::Outlook::handle_outlook_response(data, @current_account)
    elsif params[:provider] == 'google'
      success = handle_google_response(request.env['omniauth.auth'], @current_account)
    end

    if success
      redirect_to business_email_mail_path
    else
      redirect_to business_email_connect_path, notice: 'An error eccoured during processing your request. Please try again.'
    end
  end

  def set_notes_email
    success = handle_lead_notes_response(request.env['omniauth.auth'], @current_org)
    if success
      redirect_to business_settings_path, notice: 'Email account has been added successfully.'
    else
      redirect_to business_settings_path, notice: 'An error eccoured during processing your request. Please try again.'
    end
  end
end