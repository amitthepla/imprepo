class MarketingController < ApplicationController
  before_action :authorized?
  layout 'marketing'

  private
  def authorized?
    # redirect_to rails_admin_path and return if true_user.site_admin?
    raise UnauthorizedAccessError.new, "Sorry you don't have access to the requested page. Please contact your administrator." unless true_user.roles.include?(@current_org.roles.where({name: 'Administrator'}).first.id.to_s)
  end

end
