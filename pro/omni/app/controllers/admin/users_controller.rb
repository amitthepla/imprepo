class Admin::UsersController < ApplicationController
  before_filter  :authenticate_user!
  before_filter :assign_user
  
  def assign_user
     @user = current_user
     
  end

  #user list only in admin view
  def index
    @users = User.where(is_admin: false).order(:created_at)
  end

  def invite
  	user = User.where("email = ?", params[:user][:email]).first
    if !user.present?
      User.transaction do
        begin        
          user=User.new(user_params)      
          user.password = Devise.friendly_token.first(8)
        	respond_to do |format|
  	        user.skip_confirmation!

            puts "-------------> user <------------------"
            p user.valid?
          	if user.save     
              # user.confirm!   		
  	          user.invite!(@user)
  	          # flash[:notice]="Invitation email has been sent to the user."
  	          format.js  {render :nothing => true}
          	else

              puts "------------------>esle of save <----------------"
  	          alert_msg=""
  	          msgs=user.errors.messages
  	          msgs.keys.each_with_index do |m,i|
  	            alert_msg=m.to_s.camelcase+" "+msgs[m].first
  	            alert_msg += "<br />" if i > 0
  	          end
  	          p alert_msg
  	          format.json { render json: user.errors, status: :unprocessable_entity }
  	          # format.js {render text: alert_msg.to_s}
          	end
        	end
    	   rescue => e
            # raise ActiveRecord::Rollback, "Call tech support!"
    	      # format.json { render json: e.message, status: :unprocessable_entity }
           #  format.js {render text: e.message}
           render json: e.message, status: :unprocessable_entity
    	   end
      end
    else
    	 render json: "User has already been invited!", status: :unprocessable_entity
	     #render text: "User has already been invited!"
   end
  end


  def block
  	if(user = User.where(id: params[:user_id]).first).present?
  		user.update_column(:is_blocked, true)
	  	flash[:notice] = "User \'#{user.name}\' has been blocked!"
  	else
  		flash[:error] = "User not found!"
  	end	
  	redirect_to admin_users_path

  end

  def unblock
  	if(user = User.where(id: params[:user_id]).first).present?
  		user.update_column(:is_blocked, false)
	  	flash[:notice] = "User \'#{user.name}\' has been unblocked!"
  	else
  		flash[:error] = "User not found!"
  	end	
  	redirect_to admin_users_path
  end

  def change_password
      if request.put?
        if current_user.update_attributes(user_params)
          sign_in(:user, current_user)
          flash[:notice] = "Password has been changed successfully. Please login using the new password."
          redirect_to authenticated_path
        else
           flash[:error] = @user.errors.full_messages.first
           redirect_to users_change_password_path
        end
      end
  end

  def resend_invitation
    if(user = User.where(id: params[:user_id]).first).present?
      user.invite! 
      flash[:notice] = "Invitation sent successfully"
    else
      flash[:error] = "User not found!"
    end 
    redirect_to admin_users_path
  end


private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :is_blocked)
  end

end
