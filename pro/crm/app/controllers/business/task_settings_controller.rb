class Business::TaskSettingsController < ApplicationController
	layout 'business'

	def index
		@stages = @current_org.stages
    	@lead_stages = @stages.where(type: 'lead').asc(:position)
		@task_settings = @current_org.task_settings
	end

	def new
		@task_setting = @current_org.task_settings.new
		@lead_stages = @current_org.stages.where(type: 'lead').asc(:position)
	end

	def create
	    @task_setting = @current_org.task_settings.new(task_setting_params)
	    if @task_setting.save
	      redirect_to business_task_settings_path
	    else
		  @lead_stages = @current_org.stages.where(type: 'lead').asc(:position)
	      render :new
	    end
	end

	def edit
		@lead_stages = @current_org.stages.where(type: 'lead').asc(:position)
		@task_setting = Business::TaskSetting.find(params[:id])
  	end

  	def update
  		@task_setting = @current_org.task_settings.find(params[:id])
	    if @task_setting.update(task_setting_params)
	      respond_to do |format|
	        format.html { redirect_to business_task_settings_path }
	        format.json { render json: { :status => :ok, :message => "Task Setting Updated"} }
	      end
	    else
	      render :edit
	    end
  	end

	def show

	end

	private
	   def task_setting_params
	    params.require(:business_task_setting).permit(:name,:description,:duration,:stage, :auto_create, :auto_email)
	   end
end
