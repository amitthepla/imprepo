class AuthController < ApplicationController
  skip_before_action :require_login, :set_user, :set_org, :get_unread_threads, except: :pusher_auth
  layout 'public'

  def new
    respond_to do |format|
      redirect_to business_leads_path and return if current_user
      format.js {}
      format.html {}
    end
  end

  def create
    user = login(params[:email], params[:password])
    if user && user.is_active? && (user.site_admin? || user.organization.status?)
      user.update_attributes({:is_online => true})
      @path = business_leads_path
      redirect_back_or_to @path, :notice => "Welcome #{user.first_name.titleize} !"
    else
      logout
      flash.now.alert = get_error_message(user)
      render :new
    end
  end

  def destroy
    current_user.update_attributes({:is_online => false}) if current_user
    logout
    redirect_to root_url, :notice => 'You have successfully signed out!'
  end

  def pusher_auth
    if @current_account
      response = Pusher[params[:channel_name]].authenticate(params[:socket_id])
      render :json => response
    else
      render :text => 'Not authorized', :status => '403'
    end
  end

  private

  def get_error_message(user)
    if user.blank?
      'Email or password was invalid.'
    elsif !user.is_active?
      'Your account has been disabled. Please contact your administrator.'
    else
      'Your organization has been disabled. Please contact your site administrator.'
    end
  end
end
