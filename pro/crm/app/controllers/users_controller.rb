class UsersController < ApplicationController
  skip_before_action :require_login, :set_user, :set_org, :get_unread_threads, :only => [:new, :create]
  layout 'public', :only => [:new, :create]
  layout 'business', :only => [:show]

  def show
  end

  def new
    @invite = Invite.where(token: params[:id], is_active: true).first
    @user = User.new
    redirect_to login_path and return if @invite.nil?
  end

  def create
    invite = Invite.where(token: params[:user][:invite_token], is_active: true).first

    redirect_to "/invite/#{params[:user][:invite_token]}" and return if invite.nil?

    @user = invite.organization.users.new(users_params)

    if @user.save!
      invite.set(:is_active => false)
      @user.set(:roles => [invite.role.to_s])
      user = login(params[:user][:email], params[:user][:password])
      if user
        #session[:user] = { id: user.id, is_admin: user.is_admin? }
        redirect_to business_leads_path, :notice => "Signed up!"
      else
        redirect_to login_path
      end
    else
      redirect_to "/invite/#{params[:user][:invite_token]}"
    end
  end

  private

  def users_params
    params.require(:user).permit(:first_name,:last_name,:email,:password, :password_confirmation)
  end
end
