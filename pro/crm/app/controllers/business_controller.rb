class BusinessController < ApplicationController
  before_action :authorized?
  layout 'business'

  def authorized?
    return if true_user.blank? || %w(questionnaire questionnaire_submission consultation beauty_profile beauty_profile_submission).include?(action_name)
    # redirect_to rails_admin_path and return if true_user.site_admin?
    raise UnauthorizedAccessError.new, "Sorry you don't have access to the requested page. Please contact your administrator." unless true_user.can_access?(controller_path, action_name)
  end
end
