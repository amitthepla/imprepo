class Business::UsersController < BusinessController
  def index
    @users = @current_org.users
  end

  def show
    @user = @current_org.users.find(params[:id])
  end

  def new
    @invite = @current_org.invites.new
  end

  def create
    @invite = @current_org.invites.new(invite_params)
    if @invite.save
      @invite.set({is_active: true, invited_by: @current_account.first_name})
      redirect_to business_users_path
    else
      render :new
    end
  end

  def invites
    @invites = @current_org.invites
  end

  def edit
    @user = @current_org.users.find(params[:id])
    @stages = @current_org.stages
    @lead_stages = @stages.where(type: 'lead').asc(:position)
    @deal_stages = @stages.where(type: 'deal').asc(:position)
    @task_stages = @stages.where(type: 'task').asc(:position)
  end

  def update
    @user = @current_org.users.find(params[:id])
    #@stages = @current_org.stages.where(:id.in=>params[:stage])

    @user.stages=params[:stage]
    @user.change_password!(params[:password])
    if @user.update(user_params)
      flash[:success]= 'Succesfully updated user details.'
      respond_to do |format|
        format.html { redirect_to business_settings_path }
        format.json { render json: {:status => :ok, :message => 'User Updated'} }
      end
    else
      flash[:danger]= 'Unable to save updates.'
      render :edit
    end
  end

  private

  def invite_params
    params.require(:invite).permit(:first_name, :last_name, :email, :role)
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :push_channel_id, :task_visibility, {:roles => []})
  end
end
