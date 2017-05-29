require 'securerandom'
require 'rest-client'
class BetaAccountsController < ApplicationController

# /****************************************************************************************
#WakeupSales Community Edition is a web based CRM developed by WakeupSales. Copyright (C) 2015-2016

#This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 3 as published by the Free Software Foundation with the addition of the following permission added to Section 15 as permitted in Section 7(a): FOR ANY PART OF THE COVERED WORK IN WHICH THE COPYRIGHT IS OWNED BY SUGARCRM, SUGARCRM DISCLAIMS THE WARRANTY OF NON INFRINGEMENT OF THIRD PARTY RIGHTS.

#This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

#You should have received a copy of the GNU General Public License along with this program; if not, see http://www.gnu.org/licenses or write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#You can contact WakeupSales, 2059 Camden Ave. #118, San Jose, CA - 95124, US.  or at email address support@wakeupsales.org.

#The interactive user interfaces in modified source and object code versions of this program must display Appropriate Legal Notices, as required under Section 5 of the GNU General Public License version 3.

#In accordance with Section 7(b) of the GNU General Public License version 3, these Appropriate Legal Notices must retain the display of the "Powered by WakeupSales" logo. If the display of the logo is not reasonably feasible for technical reasons, the Appropriate Legal Notices must display the words "Powered by WakeupSales".

#*****************************************************************************************/

 include ApplicationHelper
  skip_before_filter :authenticate_user!, :except => [:approve, :disapprove]
 def create
  user = User.find_by_email params[:beta_account][:email]
  if user.present?
   if request.xhr?
     render :text => "Email id already registered."
   else
     flash[:warning]= "Ooops!!! You are already registered."
   end
  else
    beta_user =  BetaAccount.find_by_email params[:beta_account][:email]
    if beta_user.present?
      if request.xhr?
         render :text => "User has already sent request for beta registration."
      else
        flash[:warning]= "Ooops!!! You have already sent request for beta registration."
      end
    else
      beta_user =  BetaAccount.new params[:beta_account]
      if beta_user.save!
        if request.xhr?
          beta_user.update_attributes :is_verified=> true, :is_approved => true, :is_siteadmin_invited => true
          link = "http://#{request.env['HTTP_HOST']}/bsignup?t=" + beta_user.invitation_token
          Notification.mail_notification_for_signup_to_betauser(beta_user.email,link).deliver
        else
          link = "http://#{request.env['HTTP_HOST']}/bconfirm?token=" + beta_user.invitation_token
          Notification.mail_notification_to_betauser(beta_user.email,link).deliver
        end
      end
      unless request.xhr?
         flash[:notice] = "Thanks for registering for a beta account. Please verify your email account by clicking the verification link sent to your email address."
      else
         render :text => "success"
      end
      
      
    end
  end
  unless request.xhr?
    respond_to do |format|
     format.html { redirect_to request.referer }
    end
  end

 end


 def verify_user
   if BetaAccount.exists?(:invitation_token => params[:token])
     buser = BetaAccount.find_by_invitation_token_and_is_verified params[:token], false
     siteadmin = User.find_by_admin_type 0
     if buser.present?
       buser.update_column :is_verified, true
       flash[:notice] = "Your email account has been verified. You will soon get an instruction to signup."
       if siteadmin.present?
          #Notification.mail_notification_to_siteadmin(siteadmin.email, buser.email).deliver 
		  Notification.mail_notification_to_siteadmin("sales@wakeupsales.com", buser.email).deliver 
       end
     else   
       flash[:warning] = "Oops!!! your account has already been verified."
     end
   else
     flash[:warning] = "Oops!!! Token is invalid."
   end
   respond_to do |format|
   format.html { redirect_to root_path }
  end
 end


 def approve
   buser = BetaAccount.find params[:buser_id]
   
   if buser.update_column :is_approved, true
      ##Generate new token after admin approval
      unless buser.is_registered
        buser.update_column :invitation_token, (Digest::MD5.hexdigest "#{buser.email}-#{DateTime.now.to_s}")
        link = "http://#{request.env['HTTP_HOST']}/bsignup?t=" + buser.invitation_token
        Notification.mail_notification_for_signup_to_betauser(buser.email,link).deliver 
      end
      approve_all_users_organization(buser.email)
   end
   respond_to do |format|
     flash[:notice] = "User has been approved successfully."
     format.html { redirect_to request.referer }
   end
 end
 
 
 def disapprove
  buser = BetaAccount.find params[:buser_id]
  if buser.update_column :is_approved, false
    disapprove_all_users_organization(buser.email)  
  end
  respond_to do |format|
   flash[:notice] = "User has been disapproved successfully."
   format.html { redirect_to request.referer }
  end
 end

  def save_user_bak
    #,:confirmation_token=>nil, :confirmed_at=>Time.now
    message = ""
    ActiveRecord::Base.transaction do
      org = Organization.where("name =?", params[:user][:organization_name]).first    
      if !org.present?
        new_org = Organization.create(name: params[:user][:organization_name])
      end
      @user = User.where("email =?",params[:user][:email]).first
      if !@user.present?
        if params[:user][:name].present?
          begin
            first_name = params[:user][:name].split(" ")[0]
            last_name = params[:user][:name].split(" ")[1]
          rescue
            first_name = params[:user][:name]
            last_name = nil
          end
        else
          first_name = nil
          last_name = nil
        end

        begin
          if EmailVerifier.check(params[:user][:email])
            @user = User.create(:first_name => first_name, :last_name => last_name, :email => params[:user][:email], :password => params[:user][:password], :admin_type => org.present? ? 3 : 1)
            message = "Thanks for Signing Up. Please check your inbox to confirm your account."
          else
            @user = User.create(:first_name => first_name, :last_name => last_name, :email => params[:user][:email], :password => params[:user][:password], :confirmation_token => nil, :confirmed_at=>Time.now, :admin_type => org.present? ? 3 : 1)
            message = "Please sign in and provide a valid email."
          end
        rescue
          @user = User.create(:first_name => first_name, :last_name => last_name, :email => params[:user][:email], :password => params[:user][:password], :confirmation_token => nil, :confirmed_at=>Time.now, :admin_type => org.present? ? 3 : 1)
          message = "Please sign in and provide a valid email."
        end
      end
      @user.update_column(:organization_id, org.present? ? org.id : new_org.id)
    end
    # if @user.organization.present?
    #   redirect_to getting_started_path
    # else
    #   redirect_to new_organization_path(:id => @user.id), flash: {notice: "Provide all the required information to continue."}
    # end
    flash[:bosuccess] = message
    redirect_to root_path #, :flash => { :bosuccess => "message" }
  end

  def save_user
    #,:confirmation_token=>nil, :confirmed_at=>Time.now
    message = ""
    pwd = Devise.friendly_token[0,10]#SecureRandom.hex(5)
    ActiveRecord::Base.transaction do
      org_name = params[:user][:organization_name].strip
      user_email = params[:user][:email].strip
      org = Organization.where("name =?", org_name).first    
      @user = User.where("email =?", user_email).first
      if org.present?
        flash[:bodanger] = "This Company is already taken. Please try something else."
        redirect_to new_user_registration_path
      else
        if !@user.present?
          new_org = Organization.create(name: org_name)
          @user = User.create(:email => user_email, :password => pwd, :confirmation_token => nil, :confirmed_at=>Time.now, :admin_type => org.present? ? 3 : 1)
          Notification.mail_notification_for_password_to_betauser(@user.email,pwd).deliver
          @user.update_column(:organization_id, org.present? ? org.id : new_org.id)
          message = "Thanks for Signing Up. Password was sent to your mailbox."
          sign_in(@user, :bypass => true)
          begin
            RestClient.post 'http://blog.wakeupsales.com/auto_subscription_blog.php', {email: @user.email, domain: 'cloud'}
          rescue
          end
          begin
            if request.host.include?("wakeupsales.com")
              result = Geocoder.search(request.remote_ip)
              p "-------------------------------------------------------------------------------------------------------------------------------------------"
              #Notification.mail_notification_to_support(@user, result.first.data).deliver
            end
          rescue            
          end
          flash[:bosuccess] = message
          redirect_to "/profile" #, :flash => { :bosuccess => "message" }
        else
          flash[:bodanger] = "This Email id is already in use. Please try another one."
          redirect_to new_user_registration_path
        end
      end
    end
  end


  def new_organization

  end

  def update_organization
    org = Organization.where("name =?", params[:user][:organization_name]).first    
    if !org.present?
      org = Organization.create(name: params[:user][:organization_name], size_id: params[:user][:organization_size], website: params[:user][:organization_website])
    end
    user = User.find_by_id params[:user_id]
    user.update_column(:organization_id, org.id)
    sign_in user
    redirect_to getting_started_path
    #redirect_to root_path
  end

  def cancel_organization
    if user_signed_in?
      sign_out current_user
    end
    redirect_to root_path
  end
end
