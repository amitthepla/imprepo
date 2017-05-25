class OrganizationsController < ApplicationController
  skip_before_filter :require_login, :set_user, :set_org, :get_unread_threads, :only => [:new, :create, :check_username_availability, :check_email_availability]
  layout 'public'

  def new
    @organization = Business::Organization.new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @organization = Business::Organization.new(organization_params)
    @organization.status = true
    if @organization.valid? && @user.valid?
      @organization.save
      setup_organization_admin
      redirect_to(root_path, :notice => 'Registration successful.')
    else
      render :action => 'inquiry'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml { head :ok }
    end
  end

  def check_username_availability
    user_count = User.where({username: params[:username]}).count
    render json: {available: user_count == 0}, status: :ok
  end

  def check_email_availability
    user_count = User.where({email: params[:email]}).count
    render json: {available: user_count == 0}, status: :ok
  end

  private

  def setup_organization_admin
    role = @organization.roles.where({name: 'Administrator'}).first
    @user.is_super_admin = true
    @user.roles << role.id.to_s
    @user.organization = @organization
    @user.stages = @organization.stages.all.map(&:id).map(&:to_s)
    @user.task_visibility = 'public'
    @user.save
    @organization.update_attributes({owner_id: @user.id})
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :username, :password, :password_confirmation, :phone)
  end

  def organization_params
    params.require(:organization).permit(:company_name, :phone, :address, :city, :state, :zip, :notification_address)
  end

end
