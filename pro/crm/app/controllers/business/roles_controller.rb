class Business::RolesController < BusinessController
  def index
    @roles = @current_org.roles
  end

  def show
    @role = @current_org.roles.find(params[:id])
    
  end

  def new
    @role = @current_org.roles.new
  end

  def create
    @role = @current_org.roles.new(role_params)
    if @role.save
      redirect_to business_roles_path
    else
      render :new
    end
  end

  def update
    @role = @current_org.roles.find(params[:id])
    if @role.update(role_params)
      redirect_to @role
    else
      render :edit
    end
  end
  def save_stages
    role = Business::Role.where(:id=>params[:role_id]).first
    
    ## Add roles to stages
    # @stages = @current_org.stages.where(:id.in=>params[:stage])
    # @stages.each do |stage|
    #   if stage.roles.include?(role.id.to_s) == false 
    #     stage.roles.push(params[:role_id])
    #     stage.save
    #   end
    # end

    # ## remove roles which are not clicked
    # @remove_stages = @current_org.stages.where(:id.nin=>params[:stage])
    # @remove_stages.each do |stage|
    #   if stage.roles.include?(role.id.to_s) == true 
    #     stage.roles.delete(params[:role_id])
    #     stage.save
    #   end
    # end
    # puts "______________________________________________________"
    # p params
    # ## Change the visibility of the records to the role
    # if(params[:visibility].present?)
    #   role.visibility = params[:visibility]
    #   role.save
    #   p role.visibility
    # end
    redirect_to business_roles_path
  end
  private
   def role_params
    params.require(:business_role).permit(:name,:url)
   end
end
