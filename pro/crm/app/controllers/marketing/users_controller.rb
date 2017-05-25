class Marketing::UsersController < MarketingController
  def index
    @users = @current_org.users
  end

  def show
    @user = @current_org.users.find(params[:id])
  end

  def new
    @user = User.new
  end

  def update
  end

  def impersonate
    user = @current_org.users.find(params[:user_id])
    impersonate_user(user)
    redirect_to business_leads_path
  end

  def stop_impersonating
    stop_impersonating_user
    redirect_to business_settings_path
  end
end
