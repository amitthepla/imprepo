class PublicController < ApplicationController
  skip_before_action :require_login, :set_user, :set_org, :get_unread_threads
  layout 'public'

  def index
    redirect_to business_leads_path and return if @current_account
  end

  def thank_you
    @contact = Business::Contact.where(public_token: params[:token]).first if params[:token]
  end

  def calendar
    @contact = Business::Contact.where(public_token: params[:token]).first if params[:token]
  end

  def bank_profile
  end

end
