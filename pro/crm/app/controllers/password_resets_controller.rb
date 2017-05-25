# app/controllers/password_resets_controller.rb
class PasswordResetsController < ApplicationController
  skip_before_filter :require_login, :set_org, :set_user, :get_unread_threads
  layout 'public'
  # request password reset.
  # you get here when the user entered his email in the reset password form and submitted it.
  def create
    @user = User.where(email: (params[:email])).first

    # This line sends an email to the user with instructions on how to reset their password (a url with a random token)
    @user.generate_reset_password_token! if @user
    @url  = edit_password_reset_url(@user.reset_password_token)

    @mail = send_mail({
      :subject=> "Password Reset",
      :from_name=> "Password Reset",
      :text=>"Use the link provided to reset your password",
      :email=> @user.email,
      :name=> "#{@user.first_name}",
      :html=> render_to_string('/mail_templates/password_reset.html.erb', :layout => false, :locals => {:address => @url, :name => @user.first_name}),
      :from_email=>"notify@4beauty.net"
    })

    # Tell the user instructions have been sent whether or not email was found.
    # This is to not leak information to attackers about which emails exist in the system.
    redirect_to(root_path, :notice => 'Instructions have been sent to your email.')
  end

  # This is the reset password form.
  def edit
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    if @user.blank?
      not_authenticated
      return
    end
  end

  # This action fires when the user has sent the reset password form.
  def update
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    if @user.blank?
      not_authenticated
      return
    end

    # the next line makes the password confirmation validation work
    if params[:user][:password_confirmation] == params[:user][:password]
      # the next line clears the temporary token and updates the password
      if @user.change_password!(params[:user][:password])
        redirect_to(root_path, :notice => 'Password was successfully updated.')
      end
    else
      flash[:danger] = "Password must match password confirmation."
      render :action => "edit"
    end
  end
end
