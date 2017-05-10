class UsersController < ApplicationController

# /****************************************************************************************
#WakeupSales Community Edition is a web based CRM developed by WakeupSales. Copyright (C) 2015-2016

#This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 3 as published by the Free Software Foundation with the addition of the following permission added to Section 15 as permitted in Section 7(a): FOR ANY PART OF THE COVERED WORK IN WHICH THE COPYRIGHT IS OWNED BY SUGARCRM, SUGARCRM DISCLAIMS THE WARRANTY OF NON INFRINGEMENT OF THIRD PARTY RIGHTS.

#This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

#You should have received a copy of the GNU General Public License along with this program; if not, see http://www.gnu.org/licenses or write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#You can contact WakeupSales, 2059 Camden Ave. #118, San Jose, CA - 95124, US.  or at email address support@wakeupsales.org.

#The interactive user interfaces in modified source and object code versions of this program must display Appropriate Legal Notices, as required under Section 5 of the GNU General Public License version 3.

#In accordance with Section 7(b) of the GNU General Public License version 3, these Appropriate Legal Notices must retain the display of the "Powered by WakeupSales" logo. If the display of the logo is not reasonably feasible for technical reasons, the Appropriate Legal Notices must display the words "Powered by WakeupSales".

#*****************************************************************************************/

  include ApplicationHelper #FIXME AMT
  cache_sweeper :user_sweeper
  before_filter :authenticate_admin, :except => [:sign_up,:update_profile_image,:save_tmp_img, :get_user_email, :profile,:save_profile_info, :update, :save_password,:load_header_count_user, :invite_user, :assign_unassign_deals, :edit_user, :block_unblock_user, :grant_revoke_admin, :save_daily_updates, :manage_daily_updates, :edit_daily_update, :delete_daily_update, :assign_deal_to_user, :remove_lead, :get_users_dual_list, :update_active_inactive_users]
  before_filter :assign_user#, :except => [:profile]
  skip_before_filter  :authenticate_user!, :only => [:sign_up]
  skip_before_filter :chk_subscription_status_and_user_limit, :only => [:pricing, :get_users_dual_list, :update_active_inactive_users]
  skip_before_filter :is_trial_expired, :only => [:pricing, :get_users_dual_list, :update_active_inactive_users]
  before_filter :can_invite_user, :only => [:invite_user]
  before_filter :authenticate_super_admin, :only => [:pricing]


  def sign_up_old
    @title = "Sign Up WakeUpSales | Free CRM Tool and Client Management Software"
    @description = "WakeUpSales has the facilities for new users to sign up for new account using their personal details. User can also sign up using Google+ and LinkedIn social accounts."
  end
  def sign_in_old
    @title = "Sign In WakeUpSales | Free CRM Tool and Client Management Software"
    @description = "Registered user can sign in to WakeUpSales the free CRM tool using their personal credentials. User can also sign in using Google+ and LinkedIn social accounts."
  end
  def assign_user
     @user = current_user
     
  end
  
  
  def invite_user
   user = User.where("email = ?", params[:user][:email]).first
   if !user.present?
    begin
      user=User.new(params[:user])
      user.organization= @current_organization
      user.password = Devise.friendly_token[0,10]
      user.build_user_role(:role_id=> params[:user][:role_id], :organization_id => user.organization_id) if params[:user][:admin_type] == "3"
      respond_to do |format|
        # user.confirm!
        # user.skip_confirmation!
        if user.save
          user.invite!(@user)
          flash[:bosuccess]="Invitation email has been sent to the user."
          format.js  {render :nothing => true}
        else
          alert_msg=""
          msgs=user.errors.messages
          msgs.keys.each_with_index do |m,i|
            alert_msg=m.to_s.camelcase+" "+msgs[m].first
            alert_msg += "<br />" if i > 0
          end
         p alert_msg
        format.json { render json: user.errors, status: :unprocessable_entity }
        format.js {render text: alert_msg.to_s}
        end
      end
    rescue => e
      p e.message
      flash[:bodanger]=e.message
      redirect_to "/dashboard"
    end
   else
    if user.organization_id == @current_organization.id
     render text: "Email has already been taken!"
    else
     render text: "User is already invited by other organization!"
    end
   end
  end
  
  def edit
    @user=User.where("id=?",params[:id]).first
  end
  
  def update
    @user=User.where("id=?",params[:id]).first
        
    respond_to do |format|
      if @user.update_attributes(params[:user])
        @user.update_column :role_id, params[:user][:role_id]
        expire_fragment("user_menu_#{@user .id}") #if fragment_exist?("user_menu_#{@user .id}")
        format.html { redirect_to request.referer, notice: 'User has been updated successfully.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def index
    if params[:id].present?
      org = Organization.find(params[:id])
      @users =org.users
    else
      #@users =current_user.organization.users.includes(:user_role).where("is_active =?", true).limit(50).order("users.admin_type, user_roles.role_id").group_by{|u| !u.first_name.nil? ?  u.first_name[0].upcase : ""}
      @title = "WakeUpSales | Free CRM Tool |Admin User"
      @description = "WakeUpSales the free crm tool, admin section to manage all activities."
      #@users =current_user.organization.users.includes(:user_role).order("users.admin_type, user_roles.role_id").group_by{|u| !u.first_name.nil? && !u.first_name.blank? ?  u.first_name[0].upcase : ""}
      @users =@current_organization.users
    end
  end
  
  def destroy
    user = User.find(params[:id])
    #user.destroy
	user.update_column(:is_active,false)
    respond_to do |format|
      flash[:notice]="User successfully inactive."
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
  
  def get_user_email
    respond_to do |format|
      format.json { render json: {email: User.find(params[:id]).email}}
    end
  end

  def assign_unassign_deals
    user = @current_organization.users.find_by_id(params[:user_id])
    if params[:assign_deal_ids].present?
      assign_deals = @current_organization.deals.where("id IN (?)", params[:assign_deal_ids].split(","))
      assign_deals.map {|d| d.update_attributes(assigned_to: user.id)   }
      #Notification.send_assign_unassign_mail(user,"assign",assign_deals)
    end
    if params[:unassign_deal_ids].present?
      unassign_deals = @current_organization.deals.where("id IN (?)", params[:unassign_deal_ids].split(","))
      unassign_deals.map {|d| d.update_attributes(assigned_to: current_user.id)   }
      #Notification.send_assign_unassign_mail(user,"unassign",unassign_deals)
    end    
    @users = @current_organization.users
    render :partial => "get_users"
  end

  def update_active_inactive_users
    # current_sub = @current_organization.user_subscriptions.active.first
    # if current_sub.user_limit.to_i < @current_organization.active_users.count
    if params[:active_user_ids].present?
      active_users = @current_organization.users.where("id IN (?)", params[:active_user_ids].split(","))
      p active_users
      active_users.update_all(is_active: true)
    end
    if params[:inactive_user_ids].present?
      inactive_users = @current_organization.users.where("id IN (?)", params[:inactive_user_ids].split(","))
      inactive_users.update_all(is_active: false)
    end    
    render :text => "success"
  end

  def block_unblock_user
    user = @current_organization.users.find_by_id(params[:user_id])
    user.update_attributes(is_blocked: params[:type] == "block" ? true : false)
    render :json => {user_id: user.id, type: params[:type]}
  end

  def grant_revoke_admin
    user = @current_organization.users.find_by_id(params[:user_id])
    user.update_attributes(admin_type: params[:type] == "grant" ? 2 : 3)
    render :json => {user_id: user.id, type: params[:type]}
  end
  
  def save_password
    if @user.update_attributes(params[:user])
      sign_in(@user, :bypass => true)
      flash[:bosuccess] = "Password updated successfully."
      redirect_to "/profile"
    else
      respond_to do |format|
        format.html { render :action => "change_password" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end  
  
  def get_source_list
    render :partial=> "users/source_list"
  end
  
  def get_industry_list
    render :partial=> "users/industry_list"
  end
 def source_list
    respond_to do |format|
      format.html
      format.json { render json: SourcesDatatable.new(view_context) }
    end
  end
  # plugin integration start
  def plugin_integration
    @title = "WakeUpSales | Free CRM Tool |Plugins Integration"
    @description = "At WakeUpSales the free crm tool, registered user can integrate our customized Plugins to their account for smooth and faster work."
  end  
  # plugin integration end
  #Add a new plug in
  def add_plug_in
    user_plugin = UserPlugin.new
    user_plugin.user_id = current_user.id
    user_plugin.plugin_id = params[:id]
    user_plugin.save
    redirect_to "/plugin_integration"
  end
 def delete_source
    source = Source.find(params[:id])
    source.destroy
	respond_to do |format|
      flash[:notice]="Source has been successfully deleted."
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
 end 
  
  def industry_list
    respond_to do |format|
      format.html
      format.json { render json: IndustriesDatatable.new(view_context) }
    end
  end
  def delete_industry
    industry = Industry.find(params[:id])
    industry.destroy
	  respond_to do |format|
      flash[:notice]="Industry has been successfully deleted."
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def save_profile_info
    @user = User.find params[:name]
    if params[:pk] == '1'
      @user.update_attributes({first_name: params[:value]})
    elsif params[:pk] == '2'
      @user.update_attributes({last_name: params[:value]})
    elsif params[:pk] == '3'
      @user.phone.update_attributes({phone_no: params[:value]})
    elsif params[:pk] == '4'
      @user.update_attributes({time_zone: params[:value]})
    elsif params[:pk] == '5'
      @user.update_attributes({email: params[:value]})
    elsif params[:pk] == '6'
      @user.organization.update_attributes({name: params[:value]})
    elsif params[:pk] == '7'
      @user.organization.update_attributes({website: params[:value]})
    elsif params[:pk] == '8'
      @user.organization.update_attributes({size_id: params[:value]})
    end
    # expire_fragment("user_menu_#{@user .id}") #if fragment_exist?("user_menu_#{@user .id}")
    render :text => @user.full_name
  end
  
  def resend_invitation
    User.find(params[:user_id]).invite!
    flash[:notice]="Invitation email has been re-sent to the user."
    redirect_to request.referrer
  end
  
  def profile
    @all_users = User.where("organization_id=?",@current_organization.id)
    #@all_users =current_user.organization.users
    @title = "WakeUpSales | Free CRM Tool |User Profile"
    @description = "WakeUpSales the free crm tool registered users can manage and update their profile with required information."
   begin
     @user = params[:id].present? ? (@all_users.find(params[:id])) : @current_user
    #@user = params[:id].present? ? @all_users.find(params[:id]) : @current_user
      
   unless @current_user.is_siteadmin?
      @allowed_user =  !params[:id].present? ? true : (( params[:id].to_i == current_user.id ) || (current_user.is_admin? || current_user.is_super_admin?) ? true : false)
    end

     
   rescue ActiveRecord::RecordNotFound
      flash[:alert]="No such user exist!"
      redirect_to profile_path
    end
  
  end
  
  def enable_usr
    usr = User.find params[:id]
    usr.update_attribute(:is_active, true)
    flash[:notice]="User has been successfully activated."
    redirect_to request.referrer
  end
  
  def edit_user
   @user = User.find(params[:user_id])
    render partial: "edit_user"
  end

  def assign_deal_to_user
    @user = User.find(params[:user_id])
    render partial: "dual_list"
  end

  def remove_lead
    @user = User.find(params[:user_id])
    render partial: "remove_lead"
  end
  
  def load_header_count_user
      unless @current_user.is_siteadmin?
        @tasks=nil
        @tasks=Task.task_list(@user, "today") if @user.present?
	    @tasks = @tasks.limit(10) if @tasks.present?
        @task_type="today"      
        count_condition=get_deal_status_count_user([1,2,3,4,5,6,7,8],@user)
        @new_ds=@current_organization.deal_statuses.where("name=?","New").first
        @qualified_ds=@current_organization.deal_statuses.where("name=?","Qualified").first
        @new_deals = @new_ds.present? ? @current_organization.deals.where(:is_active=>true,:deal_status_id=>@current_organization.filter_deal_status(@new_ds.id,@current_organization.id).id).count : 0
        @qualified_deals = @ualified_ds.present? ? @current_organization.deals.where(:is_active=>true,:deal_status_id=>@current_organization.filter_deal_status(@qualified_ds.id,@current_organization.id).id).count : 0

        #@new_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("deal_statuses.original_id IN (?) ", [1]).count
        @working_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("deal_statuses.original_id IN (?) AND is_current=? ", [1,2,3,4,5,6], true).count
        #@qualified_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("deal_statuses.original_id IN (?)", [2]).count
        #@deals = @user.all_assigned_or_created_deals.limit(10)
      
          if badge_today_user(@user) > 0
            @task_count = badge_today_user(@user)
            @task_text="Today's tasks"
            @task_url = "/tasks?type=today"
          elsif badge_overdue_user(@user) > 0
            @task_count = badge_overdue_user(@user)
            @task_text="Overdue tasks"
            @task_url = "/tasks?type=overdue"
          elsif badge_upcoming_user(@user) > 0
            @task_count = badge_upcoming_user(@user)
            @task_text="Upcoming tasks"
            @task_url = "/tasks?type=upcoming"
          else
            @task_count = badge_all_user(@user)
            @task_text="Tasks"
            @task_url = "/tasks"
          end
          @allowed_user =  !params[:id].present? ? true : (( params[:id].to_i == current_user.id ) || (current_user.is_admin? || current_user.is_super_admin?) ? true : false)
          render partial: "user_load_header_count_section", :content_type => 'text/html'
     end
  end
def save_tmp_img
    text="fail"
    #if remotipart_submitted?
	puts ">>>>>>>>>>>..this is before checking user"
      @user=User.where("id=?", params[:user_id]).first
	  p @user
	  puts ">>>>>>>>>>>..getting user"
      if @user.present?
	   begin
	   puts ">>>>>>>>>>>..if useris present"
	   @tempImage= TempImage.create!(:user_id=> @user.id, :avatar=> params[:user][:profile_image])
	   text="success" if !@tempImage.nil?
	   rescue => e
	    p e.message
		p e.backtrace
	    text="fail" 
	   end
      end
    #end
    if text=="success"
      render partial: "crop"
    else
      render :text => text
    end
  end
  
  
  def update_profile_image
	@user=User.where("id=?",params[:user_id]).first	
	
	respond_to do |format|
	  @tmpimage=TempImage.find params[:id]
	  @tmpimage.crop_x =params["temp_image"]["avatar"]["crop_x"]
	  @tmpimage.crop_y =params["temp_image"]["avatar"]["crop_y"]
	  @tmpimage.crop_w =params["temp_image"]["avatar"]["crop_w"]
	  @tmpimage.crop_h =params["temp_image"]["avatar"]["crop_h"]
    @tmpimage.crop
	  
    unless @user.image.present?
      @user.image = Image.create!( :organization => @current_organization, :imagable => @user )
    end
	  if(@user.image.update_attribute :image,@tmpimage.avatar)
        expire_fragment("user_menu_#{@user.id}")
    		@tmpimage.destroy
    		format.json{render json: {imagesmall: @user.image.image.url(:thumb), imagesmall: @user.image.image.url(:small) ,imageicon: @user.image.image.url(:icon)}}
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  def save_daily_updates
    @deal = Deal.find_by_id(params[:hdn_deal_id])
    if @deal.present? && @deal.daily_update.present?
      @deal.daily_update.update_attributes(:deal_id=>params[:hdn_deal_id], :time_zone=>params[:daily_updates][:time_zone], :user_ids => params[:hdn_user_ids], :frequency=>params[:hdn_frequency], :alert_time => params[:daily_updates]['alert_time(4i)'] + ":" + params[:daily_updates]['alert_time(5i)'])
    else
      DailyUpdate.create(:deal_id=>params[:hdn_deal_id], :time_zone=>params[:daily_updates][:time_zone], :user_ids => params[:hdn_user_ids], :frequency=>params[:hdn_frequency], :alert_time => params[:daily_updates]['alert_time(4i)'] + ":" + params[:daily_updates]['alert_time(5i)'])
    end
    flash[:notice] = "Daily update saved successfully."
    if request.referrer.include?("manage_daily_update")
      redirect_to "/manage_daily_updates"
    else
      redirect_to "/daily_updates"
    end
  end

  def manage_daily_updates
    @daily_updates = @current_organization.deals.map {|d| d.daily_update}.compact
  end

  def edit_daily_update
    @daily_update = DailyUpdate.find_by_id params[:id]
    @deal = @daily_update.deal
    users = []
    users << @deal.assigned_user
    @deal.tasks.map{|t|t.user}.each do |user|
      users << user
    end
    @users = users.uniq
    render :partial => "edit_daily_update"
  end

  def delete_daily_update
    @daily_update = DailyUpdate.find_by_id params[:id]
    if @daily_update.destroy
      flash[:notice] = "Daily update deleted successfully."
    else
      flash[:error] = "Something went wrong."
    end
    redirect_to manage_daily_updates_path
  end

  def resend_invite
    begin
      user = User.find_by_id params[:user_id]
      user.invite!(@user)
      render :json => {user_email: user.email, status: "success"}
    rescue
      render :json => {status: "error"}
    end
  end
  
  def pricing
    #@u_subs = @current_user.user_subscriptions.last
  end

  def get_users_dual_list
    @inactive_users = @current_organization.users.by_inactive
    @active_users = @current_organization.users.by_active
    render partial: "users_dual_list"
  end

private
  def can_invite_user       
    if @current_organization.trial_expired?   
    # unless @current_organization.trial_expires_on > Time.now.to_datetime
      current_sub = @current_organization.user_subscriptions.last 
      #checking user limit 
      if current_sub.user_limit.to_i == @current_organization.users.count        
          render :text => "User  limit exceeded", status: :unprocessable_entity 
          # render json: @user.errors, status: :unprocessable_entity 
          return false
      end
    end
  end
end