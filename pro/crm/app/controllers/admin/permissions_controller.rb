class Marketing::PermissionsController < MarketingController

  before_filter :set_role_permission, only: [:edit, :update]

  def index
    @roles = @current_org.roles
  end

  def edit
    @stages = @current_org.stages
    @lead_stages = @stages.where(type: 'lead').asc(:position)
    @deal_stages = @stages.where(type: 'deal').asc(:position)
    @task_stages = @stages.where(type: 'task').asc(:position)
  end

  def update
    begin
      pem = nil
      if @role.permission.present?
        @role.permission.update_attributes!({stages: params[:stages], visibility: params[:task_visibility]})
      else
        pem = @current_org.permissions.create!({stages: params[:stages], visibility: params[:task_visibility]})
        @role.permission = pem
        @role.save!
      end
      redirect_to admin_roles_path, notice: 'Successfully saved changes.'
    rescue
      pem.destroy if pem.present?
      redirect_to admin_edit_permissions_path(@role), error: 'An error occured while saving your changes. Please try again.'
    end

  end

  private

  def set_role_permission
    @role = @current_org.roles.find(params[:id])
    @permission = @role.permission || Business::Permission.new
  end
end
