class LandingPagesController < ApplicationController
  skip_before_action :require_login, :set_user, :set_org, :get_unread_threads
  layout 'landing_pages'

  def mothers_day_viva_1
  end

  def free_bag_procedure_summer_2015
  end

  def home

  end

end
