require 'unauthorized_access_error'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format.json? }

  before_action :require_login, :set_user, :set_org
  before_action :get_unread_threads

  impersonates :user


    def is_admin?(user)
      user.roles.include?(user.organization.roles.where({name: 'Administrator'}).first.id.to_s)
    end

  def not_authenticated
    redirect_to '/login', :alert => 'First login to access this page.'
  end

  rescue_from ::UnauthorizedAccessError do |exception|
    flash[:error] = exception.message
      redirect_to business_leads_path
  end

  def debug_me(object)
    Rails.logger.debug '===' * 50
    Rails.logger.debug object.inspect
    Rails.logger.debug '===' * 50
  end

  def send_mail(params)
    require 'mandrill'
    m = Mandrill::API.new
    message = {
        :subject => params[:subject],
        :from_name => params[:from_name],
        :text => params[:text],
        :to => [
            {
                :email => params[:email],
                :name => params[:name]
            }
        ],
        :html => params[:html],
        :from_email => params[:from_email]
    }
    m.messages.send message
  end

  def lead_template(type, language)
    path = '/mail_templates'
    templates = {:bbl => 'new_lead_bbl', :breast => 'new_lead_breast', :mommy => 'new_lead_mommy', :mendieta_technique => 'new_lead_mendieta_technique', :lipo => 'new_lead_lipo'}
    template = templates[type.to_sym].nil? ? 'new_lead_general' : templates[type.to_sym]
    "#{path}/#{language}/#{template}"
  end

  def active_coordinator(coordinator)
    user = User.find(coordinator)
    org = user.organization
    rotation = org.settings.where(:setting_id => 'coordinator_rotation').first

    if rotation.data.include? (user.id.to_s)
      true
    else
      false
    end
  end


  private

  def set_user
    @current_account = current_user
  end

  def set_org
    @current_org = @current_account.organization
  end

  def get_unread_threads
    @unread_channels = @current_account.unread_threads
  end

end
