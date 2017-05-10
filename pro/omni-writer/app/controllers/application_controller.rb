class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :check_user_status



 def check_user_status
  if current_user && current_user.is_blocked
	  flash[:alert] = "Your account is not active!!"
	  sign_out(current_user)
	  redirect_to "/users/sign_in"
  end
 end

end
