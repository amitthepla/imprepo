require 'will_paginate/array'
class Business::TasksController < BusinessController
  before_action :set_task, only: [:show, :edit, :update, :destroy, :complete_task]

  def index
    @task = @current_org.tasks.new
    if params[:old].present? || params[:start_date].present? || params[:end_date].present?
      params[:today] = nil
    else
      params[:today] = 'TODAY'
    end

    current_account_roles = @current_org.roles.where({:id.in => @current_account.roles}).map(&:name)
    if current_account_roles.include?('Receptionist')
      @stages = [%w(Inquiry inquiry)]
      @all_tasks = @current_account.new_lead_tasks(@current_org.tasks, params[:stage]).due_date_old(params[:old]).due_date_today(params[:today]).due_date_search(params[:start_date], params[:end_date]).desc(:due_date)
    elsif current_account_roles.include?('Sales Coordinator')
      @stages = [%w(Inquiry inquiry), ['Booked Consult', 'booked_consult'], ['Booked Surgery', 'booked_surgery']]
      @all_tasks = @current_account.coordinator_lead_tasks(@current_org.tasks, params[:stage]).due_date_old(params[:old]).due_date_today(params[:today]).due_date_search(params[:start_date], params[:end_date]).desc(:due_date)
    elsif current_account_roles.include?('Pre-Op Nurse')
      @stages = [['Booked Surgery', 'booked_surgery'], ['Pre Op', 'pre_op']]
      @all_tasks = @current_org.admin_lead_tasks(@current_org.tasks, params[:stage]).due_date_old(params[:old]).due_date_today(params[:today]).due_date_search(params[:start_date], params[:end_date]).desc(:due_date)
    else
      if @current_account.is_public?
        @stages = [%w(Inquiry inquiry), ['Booked Consult', 'booked_consult'], ['Booked Surgery', 'booked_surgery'], ['Pre Op', 'pre_op'], ['Post Op', 'post_op'], ['Cold', 'cold']]
        @all_tasks = @current_org.admin_lead_tasks(@current_org.tasks, params[:stage]).due_date_old(params[:old]).due_date_today(params[:today]).due_date_search(params[:start_date], params[:end_date]).desc(:due_date)
      else
        @stages = [%w(Inquiry inquiry), ['Booked Consult', 'booked_consult'], ['Booked Surgery', 'booked_surgery'], ['Post Op', 'post_op'], ['Cold', 'cold']]
        @all_tasks = @current_account.lead_tasks(@current_org.tasks, params[:stage]).due_date_old(params[:old]).due_date_today(params[:today]).due_date_search(params[:start_date], params[:end_date]).desc(:due_date)
      end
    end

    @tasks = @all_tasks.paginate(:page => params[:page])
    @tasks_count = @all_tasks.count
    if request.xhr?
      render partial: '/business/tasks/tasks_listing'
    end
  end

  def show
    @notes = @task.notes
    @note = @task.notes.new
    @created_by = @current_org.users.where(id: @task.created_by).first
  end

  def new
    @task = @current_org.tasks.new
  end

  def create
    @lead_id = params[:business_task][:lead_id]
    if @lead_id.present? && (lead = Business::Lead.where(id: @lead_id).first)
      @lead = lead
      @task = @lead.tasks.new(task_params)
      @task.organization = @current_org
    else
      @task = @current_org.tasks.new(task_params)
    end
    @task.stage = 'inquiry'
    @task.created_by = @current_account.id
    if @task.save
      respond_to do |format|
        format.html { redirect_to (!@task.lead.nil? ? business_lead_path(@task.lead) : @task) }
        format.json { render json: {:status => :ok, :message => 'Task Created'} }
      end
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @task.update(task_params)
      unless @task.lead.nil?
        if @task.stage == 'completed'
          if @task.title.match(/Initial Follow up with|New - First Phone Call|Qualified - First Phone Call/i) # Change status to Follow up with Dr. Mendieta
            @task.lead.set(status: BSON::ObjectId.from_string('54e758a032643000030f0000'))
          end
          if @task.title.match(/Second Follow up with|New - Second Phone Call|Qualified - Final Phone Call/i) #Move lead into cold.
            @task.lead.set(stage: 'cold')
            @task.lead.push(stage_lifecycle: {:stage => 'cold', :timestamp => Time.now})
          end
          if @task.title.match(/Qualified - Second Phone Call/i)
            t = @task.lead.tasks.new
            t.title = "Qualified - Final Phone Call with #{@task.lead.contact.first_name}"
            t.description = "Call patient at #{@task.lead.contact.phone}"
            t.stage = 'inquiry'
            t.lead_id = @task.lead.id
            t.organization_id = @task.lead.organization_id
            t.priority = '9 - High'
            t.due_date = Time.now + 72.hours
            t.save!
            @task.lead.set(status: BSON::ObjectId.from_string('54e7588c32643000030d0000')) # Final Follow Up
          end
          ## Commented on 15-dec-2015, as per new requirement, when task is deleted manually it should not be cold lead
          # elsif @task.stage == 'deleted'
          #   @task.lead.set(stage: 'cold')
          #   @task.lead.push(stage_lifecycle: { :stage => 'cold', :timestamp => Time.now })
        end
      end
      respond_to do |format|
        format.html { redirect_to (!@task.lead.nil? ? business_lead_path(@task.lead) : @task) }
        format.json { render json: {:status => :ok, :message => 'Task Updated'} }
      end
    else
      render :edit
    end
  end

  def destroy
    @task.destroy
    redirect_to request.referrer, :notice => 'Task deleted.'
  end

  def final_task
    @lead = Business::Lead.find_by(id: params[:lead_id])
    @task = Business::Task.find_by(id: params[:id])
    @task.update_attribute(:stage, 'completed')

    if params[:stage] == 'post_op'
      @lead.update_attribute(:surgery_completed, true)
    end

    @lead.update_attribute(:stage, params[:stage])

    @task.save
    @lead.save


    if @lead.stage == 'inquiry' && @lead.contact.account_rep_id && @lead.activities.where(body: 'Coordinator Intro e-mail was sent.').count == 0
      @contact = @lead.contact
      @mail = send_mail({
                            :subject => "#{@contact.first_name.titleize}, your consultation is almost here",
                            :from_name => @contact.account_rep.full_name,
                            :text => 'Thank you for contacting the offices of Dr. Mendieta',
                            :email => @contact.email,
                            :name => "#{@contact.first_name} #{@contact.last_name}",
                            :html => render_to_string('/mail_templates/coordinator_intro', :layout => false, :locals => {:first_name => @contact.first_name, :questionnaire_id => @contact.public_token}),
                            :from_email => @contact.account_rep.email
                        })
      @lead.activities.create(body: 'Coordinator Intro e-mail was sent.')
      @lead.notes.create(body: 'Coordinator Intro e-mail was sent.')

    end

    redirect_to request.referrer
  end

  def not_final_task
    @lead = Business::Lead.find_by(id: params[:lead_id])
    @task = Business::Task.find_by(id: params[:task_id])
    @task.update_attribute(:stage, 'completed')
    @task.save
    communication_method = params[:communication_method]

    t = @lead.tasks.new
    t.title = "Task created for #{@lead.stage.titleize} stage."
    t.description = "#{communication_method} patient at #{(communication_method == 'Call' || communication_method == 'Text') ? number_to_phone(@lead.phone).to_s : @lead.email.to_s}"
    t.communication = params[:communication_method]
    t.stage = 'inquiry'
    t.lead_id = @lead.id
    t.organization_id = @lead.organization_id
    t.due_date = Date.strptime(params[:due_date], '%m/%d/%Y')
    t.save
    redirect_to request.referrer
  end

  def new_lead_task
    @task = @current_org.tasks.new
    @lead = Business::Lead.find_by(id: params[:id])
  end

  def receptionist_view
    @current_account.set(stages: ["54b0053b3931620002020000", "54cfbf0b3233660003020000", "54cfbf2c3233660003060000"])
    @current_account.set(task_visibility: "public")
    @current_account.set(view: "Receptionist")
    redirect_to business_tasks_path
  end

  def coordinator_view
    @current_account.set(stages: ["54b0053b3931620002020000", "54b0053c3931620002030000", "54c911623635350003040000", "54c911703635350003070000", "54cfbf0b3233660003020000", "54cfbf2c3233660003060000"])
    @current_account.set(task_visibility: "own")
    @current_account.set(view: "Sales Coordinator")
    redirect_to business_tasks_path
  end


  private

  def set_task
    @task = @current_org.tasks.find(params[:id])
  end

  def task_params
    params[:business_task][:due_date] = DateTime.strptime(params[:business_task][:due_date], '%Y-%m-%d')
    params.require(:business_task).permit(:title, :description, :due_date, :created_by, :user, :stage, :lead_id, :priority)
  end
end
