include ActionView::Helpers::NumberHelper
class Business::LeadsController < BusinessController
  require 'will_paginate/array'
  require 'csv'
  before_action :set_lead, only: [:show, :edit, :update, :destroy, :save_treatment]
  before_action :set_promote, only: [:promote_lead]
  skip_before_action :require_login, :set_user, :set_org, :get_unread_threads, only: [:questionnaire, :questionnaire_submission]
  layout 'public', only: [:questionnaire, :new]
  helper_method :sort_column, :sort_direction

  def source_options
    content = {}
    sources = SourceType.find(params[:id]).sources.where(organization_id: current_user.organization.id,:start_date.lte => Date.today, :end_date.gte => Date.today)
    sources.each { |source| content[source.id.to_s] = source.name }
    render json: content
  end


  def index
    if @current_account.is_public? || (['Pre-Op Nurse', 'Post-Op Nurse'] & @current_org.roles.where({:id.in => @current_account.roles}).map(&:name)).present?
      @leads = @current_org.leads.search(params[:search]).coordinator_search(params[:coordinator]).creator_search(params[:created_by]).date_range(params[:start_date], params[:end_date]).includes(:contact, :user, :tasks, :activities).desc(:created_at)
    else
      @leads = @current_org.leads.where(user: current_user).search(params[:search]).creator_search(params[:created_by]).date_range(params[:start_date], params[:end_date]).includes(:contact, :user, :tasks, :activities).desc(:created_at)
    end

    @statuses = @current_org.statuses
    if request.xhr?
      stage_leads = @leads.where(stage: params[:stage_id]).includes(:contact, :user, :tasks, :activities)
      @stage_leads_count = stage_leads.count
      @stage_leads = stage_leads.page(params[:page])
      @stage = @current_org.stages.where(type: 'lead', stage_id: params[:stage_id]).asc(:position).first
      render partial: '/business/leads/leads_listing'
    else
      @stages = @current_org.stages.where(:_id.in => (current_user.stages)).asc(:position)
    end

    sales = @current_org.roles.where({name: 'Sales Coordinator'}).first
    sales_users = sales.present? ? @current_org.users.where({roles: sales.id.to_s}) : []

    @coordinators = sales_users
    if User.where(:role_id => '56f2d9ff495473069a200000').first
      @coordinators.push(User.where(:role_id => '56f2d9ff495473069a200000').first)
    end
    roles = Business::Role.where(:name.in => ["Surgeon", "Physician Assistant"]).collect(&:id).map(&:to_s)
    @physicians = @current_org.users.where(:roles.in => roles)

    respond_to do |format|
      format.html
      format.csv { send_data @leads.to_csv }
    end
  end

  def stage_leads
    if @current_account.is_public? || (['Pre-Op Nurse', 'Post-Op Nurse'] & @current_org.roles.where({:id.in => @current_account.roles}).map(&:name)).present?
      @leads = @current_org.leads.search(params[:search]).coordinator_search(params[:coordinator]).creator_search(params[:created_by]).date_range(params[:start_date], params[:end_date]).where(stage: params[:stage_id]).includes(:contact, :user, :tasks, :activities).desc(:created_at)
    else
      @leads = @current_org.leads.where(user: current_user).search(params[:search]).creator_search(params[:created_by]).date_range(params[:start_date], params[:end_date]).where(stage: params[:stage_id]).includes(:contact, :user, :tasks, :activities).desc(:created_at)
    end
    roles = Business::Role.where(:name.in => ["Surgeon", "Physician Assistant"]).collect(&:id).map(&:to_s)
    @physicians = @current_org.users.where(:roles.in => roles)

    @stage_leads_count = @leads.count
    @stage_leads = @leads.page(params[:page])
    @stage = @current_org.stages.where(type: 'lead', stage_id: params[:stage_id]).asc(:position).first
    render partial: '/business/leads/leads_listing'
  end

  def show
    @lead.activities.create(body: "#{true_user.full_name} viewed lead.")

    if @lead.surgery.present?
      @surgery = @lead.surgery
    else
      @surgery = Business::Surgery.new
    end

    if @lead.consultation.present?
      @consultation = @lead.consultation
    else
      @consultation = Business::Consultation.new
    end

    roles = Business::Role.where(:name.in => ["Surgeon", "Physician Assistant"]).collect(&:id).map(&:to_s)
    @physicians = @current_org.users.where(:roles.in => roles)

    @contact = @lead.contact
    @notes = @lead.notes.desc(:created_at)
    @note = @lead.notes.new
    @task = @lead.tasks.new
    @tasks = @lead.tasks.desc(:created_at)
    @stages = @current_org.stages.where(type: 'task').asc(:position)
  end

  def new
    sales = @current_org.roles.where({name: 'Sales Coordinator'}).first
    sales_users = sales.present? ? @current_org.users.where({roles: sales.id.to_s}).entries : []
    @lead = @current_org.leads.new
    @sales_coordinators = sales_users
    @contact = @current_org.contacts.new
    @phone_message = @current_org.phone_messages.new
    @procedures = @current_org.procedures.all
  end

  def injectable_leads
    @leads = @current_org.leads.where(spa: true).desc(:created_at)
  end

  def create

    if params[:date_of_birth].present?
      dob = Date.strptime(params[:date_of_birth], '%m/%d/%Y')
    end

    @contact = @current_org.contacts.find_or_create_by(email: params[:business_lead][:email].downcase.strip)
    if @contact.new_record?
      @contact.set({
                       first_name: params[:business_lead][:first_name].downcase.strip,
                       last_name: params[:business_lead][:last_name].downcase.strip,
                       phone: params[:business_lead][:phone],
                       gender: params[:business_lead][:gender],
                       address: params[:business_lead][:address],
                       city: params[:business_lead][:city],
                       state: params[:business_lead][:state],
                       zip: params[:business_lead][:zip],
                       referral: params[:business_lead][:referral],
                       preffered_language: params[:preffered_language],
                       weight: params[:business_lead][:weight],
                       height: params[:business_lead][:height],
                       date_of_birth: dob
                   })
    end
    @contact.preffered_language = params[:preffered_language]
    @contact.external_record_id = params[:external_record_id] if params[:external_record_id]
    @lead = @contact.leads.new(lead_params)
    @lead.created_by = true_user.is_super_admin? ? 'CRM' : true_user.id

    @lead.organization_id = @current_org.id
    @lead.contact = @contact
    @lead.contact.date_of_birth = dob
    @lead.date_of_birth = dob
    #assign coordinator to lead

    if  params[:business_lead][:user].present?
      @contact.account_rep_id = params[:business_lead][:user]
    end

    @current_coordinator = @contact.account_rep_id || (@lead.user.nil? ? nil : @lead.user.id)
    @sales_coordinator_rotation = @lead.organization.settings.where(:setting_id => 'coordinator_rotation').first
    @sales_coordinator = @current_coordinator.nil? ? BSON::ObjectId.from_string(@sales_coordinator_rotation.data[0]) : ( active_coordinator(@current_coordinator) ? @current_coordinator : BSON::ObjectId.from_string(@sales_coordinator_rotation.data[0]))
    @lead.set({:stage => 'temp_stage', :user => @sales_coordinator})
    @lead.push(stage_lifecycle: {:stage => params[:business_lead][:stage], :timestamp => Time.now})
    @contact.set(account_rep_id: @sales_coordinator)
    @sales_coordinator_rotation.set(:data => @sales_coordinator_rotation.data.rotate())
    @lead.save

    Pusher.trigger("private-#{@lead.user.push_channel_id}", 'message', {:from => @current_account.first_name, :subject => 'has assigned a New Lead to you.'}) if @lead.user != params[:business_lead][:user] && @current_account.id != params[:business_lead][:user]

    @lead.update_attribute(:stage, "inquiry")

    if @lead.save! && @contact.save!

      @contact.questionnaire.set(params[:business_lead][:questionnaire]) if (params[:business_lead][:questionnaire])
      @lead.activities.create(body: "#{true_user.full_name} created the lead.") if !true_user.is_super_admin?

      if params[:coordinator_intro].present?
        first_message = render_to_string('/mail_templates/en/new_lead_general', :layout => false, :locals => {:first_name => @lead.first_name.titleize, :questionnaire_id => @contact.public_token, user_name: @lead.user.first_name.titleize})
        @mail = send_mail({
                              :subject => 'Welcome to 4Beauty',
                              :from_name => "#{@lead.user.first_name.titleize} and the #{@current_org.company_name.titleize} Team",
                              :text => 'Thank you for contacting the offices of Dr. Mendieta',
                              :email => params[:business_lead][:email],
                              :name => "#{params[:business_lead][:first_name]} #{params[:business_lead][:last_name]}",
                              :html => first_message,
                              :from_email => "#{@lead.user.email}"
                          })
        @lead.notes.create(body: "First email sent to #{@lead.first_name}.")
        @lead.activities.create(body: "First email was sent to #{@lead.first_name}.")
        @lead.messages.create(body: first_message, type: "text", contact: @lead.contact, user: @current_account, organization: @lead.organization)
        TextWorker.perform_in(1.minute, @lead.id)
      else
        @lead.notes.create(body: 'Coordinator opted out of intro.', user_id: @current_account.id)
        @lead.messages.create(body: 'Coordinator opted out of intro.', type: "text", contact: @lead.contact, user: @current_account, organization: @lead.organization)
        @lead.activities.create(body: 'Coordinator opted out of intro.')
      end

      begin
        send_mail({
                      :subject => 'New Lead was created',
                      :from_name => '4Beauty CRM',
                      :text => 'New lead was created.',
                      :email => @lead.user.email,
                      :name => "#{@current_org.company_name.titleize} Team",
                      :html => render_to_string('/mail_templates/new_lead_created', :layout => false, :locals => {:first_name => @lead.first_name.titleize, :lead_id => @lead._id, :user => @lead.user.first_name.titleize}),
                      :from_email => 'concierge@4beauty.net'
                  })
      rescue
        Rails.logger.info 'Failed to send email'
      end
      message_setting = @current_org.settings.where(name: 'messaging').first.data
      TextWorker.perform_in(message_setting[0].days, @lead.id)
      second_email = render_to_string('/mail_templates/en/new_lead_second_contact', :layout => false, :locals => {:first_name => @lead.first_name.titleize, :questionnaire_id => @contact.public_token, user_name: @lead.user.first_name.titleize})
      EmailWorker.perform_in(message_setting[0].days, @lead.id, second_email)
      TextWorker.perform_in(message_setting[1].days, @lead.id)
      third_email = render_to_string('/mail_templates/en/new_lead_third_contact', :layout => false, :locals => {:first_name => @lead.first_name.titleize, :questionnaire_id => @contact.public_token, user_name: @lead.user.first_name.titleize})
      EmailWorker.perform_in(message_setting[1].days, @lead.id, third_email)

      MigrateWorker.perform_in(message_setting[2].days, @lead.id)

      redirect_to @lead
    else
      @sales_coordinators = @current_org.roles.where('name' => 'Sales Coordinator').first.users
      render :new
    end
  end

  def edit
    #@lead = @current_org.leads.where(:id=> params[:id])
    sales = @current_org.roles.where({name: 'Sales Coordinator'}).first
    @sales_coordinators = sales.present? ? @current_org.users.where({roles: sales.id.to_s}).entries : []
  end

  def update
    # params[:business_lead].delete(:user) if params[:business_lead][:user] && params[:business_lead][:user].empty?
    # @lead.push(stage_lifecycle: {:stage => params[:business_lead][:stage], :timestamp => Time.now}) if @lead.stage != params[:business_lead][:stage]

    # if @lead.contact.present?
    #   @lead.contact.set(account_rep_id: params[:business_lead][:user]) if params[:business_lead][:user] && !params[:business_lead][:user].empty?
    # end

    if @lead.update(lead_params)
      @lead.set(date_of_birth: DateTime.strptime(params[:business_lead][:date_of_birth], '%m/%d/%Y')) if params[:business_lead][:date_of_birth].present?
      @lead.activities.create(body: "#{true_user.full_name} updated lead.")
      @lead.save
      Pusher.trigger("private-#{@lead.user.push_channel_id}", 'message', {:from => @current_account.first_name, :subject => 'has assigned a New Lead to you.'}) if @lead.user != params[:business_lead][:user] && @current_account.id != params[:business_lead][:user]
      flash[:success] = 'Updated Lead Info'
      respond_to do |format|
        format.html { redirect_to @lead }
        format.json { render json: {:status => :ok, :message => 'Lead Updated'} }
      end
    else
      render :edit
    end
  end

  def destroy
    @lead.destroy
    redirect_to business_leads_path, :notice => 'Lead deleted.'
  end

  def show_questionnaire
    @lead = @current_org.leads.where(:id => params[:lead_id]).first
    @notes = @lead.notes
  end

  def duplicate_leads
    require 'will_paginate/array'
    @duplicate_collection = @current_org.leads.collection.aggregate([
                                                                        {'$group' => {
                                                                            _id: {email: '$email'},
                                                                            lead: {'$addToSet' => '$_id'},
                                                                            first_name: {'$addToSet' => '$first_name'},
                                                                            last_name: {'$addToSet' => '$last_name'},
                                                                            procedure: {'$addToSet' => '$interested_in'},
                                                                            created_at: {'$addToSet' => '$created_at'},
                                                                            stage: {'$addToSet' => '$stage'},
                                                                            count: {'$sum' => 1}
                                                                        }
                                                                        },
                                                                        {'$match' => {
                                                                            count: {'$gt' => 1}
                                                                        }
                                                                        },
                                                                        {'$sort' => {
                                                                            count: -1
                                                                        }}
                                                                    ])



    @duplicate_leads = []
    @duplicate_collection.each do |dupe|
      dates = dupe["created_at"].map(&:beginning_of_day)
      indices = []
      dates.length.times do |x|
        counts = dates.count(dupe["created_at"].map(&:beginning_of_day)[x])
        indices.push(x) if counts > 1
      end
      dupe['lead'].each_with_index do |lead, n|
        next unless indices.include?(n)
        @duplicate_leads.push(@current_org.leads.find_by(id: lead))
      end
    end

    # @duplicate_leads.page params[:page]
    @dupes = Kaminari.paginate_array(@duplicate_leads).page params[:page]

  end

  def delete_duplicates
    dupes = params['delete_dupes']
    dupes.each do |dupe|
      @current_org.leads.find_by(id: dupe).destroy
    end
    redirect_to request.referrer
  end

  def resend_questionnaire
    begin
      @lead = @current_org.leads.where(:id => params[:lead_id]).first
      @contact = @lead.contact
      @lead.activities.create(body: "#{true_user.full_name} resent the questionnaire e-mail.") unless true_user.is_super_admin?
      @lead.notes.create(body: "#{true_user.full_name} resent the questionnaire e-mail.", user_id: @current_account.id)
      @mail = send_mail({
                            :subject => 'Your Beauty Profile',
                            :from_name => @lead.user.full_name,
                            :text => 'Thank you for contacting the offices of Dr. Mendieta',
                            :email => @lead.email,
                            :name => "#{@contact.first_name} #{@contact.last_name}",
                            :html => render_to_string('/mail_templates/resend_beauty_profile', :layout => false, :locals => {:first_name => @contact.first_name.titleize, :questionnaire_id => @contact.public_token, :user_name => @lead.user.full_name}),
                            :from_email => @lead.user.email
                        })

      @contact.questionnaire.set({:questionnaire_sent => (@mail[0]['reject_reason'].nil? ? true : false), :questionnaire_filled => false})

      flash[:success] = 'Successfully resent questionnaire.'
      redirect_to @lead
    rescue
      Rails.logger.info 'Failed to send email'
      flash[:error] = 'Failed to resend questionnaire.'
      redirect_to @lead
    end
  end

  def send_first_followup_email
    @lead = @current_org.leads.where(:id => params[:lead_id]).first
    @contact = @lead.contact
    @mail = send_mail({
                          :subject => "Hello #{@contact.first_name.titleize}, This is Dr. Mendieta",
                          :from_name => 'Dr. Constantino Mendieta',
                          :text => 'Thank you for contacting the offices of Dr. Mendieta',
                          :email => @contact.email,
                          :name => "#{@contact.first_name} #{@contact.last_name}",
                          :html => render_to_string('/mail_templates/follow_up_dr_mendieta', :layout => false, :locals => {:first_name => @contact.first_name.titleize, :questionnaire_id => @contact.public_token}),
                          :from_email => 'concierge@4beauty.net'
                      })
    t = @lead.tasks.new
    t.title = "New - Second Phone Call with #{@contact.first_name}"
    t.description = "Call patient at #{@contact.phone}"
    t.stage = 'inquiry'
    t.lead_id = @lead.id
    t.organization_id = @lead.organization_id
    t.priority = 9
    t.due_date = Time.now + 24.hours
    t.save
    @lead.set(status: BSON::ObjectId.from_string('54e7587832643000030b0000')) # Second Follow Up (Follow Up - Second)
    redirect_to @lead
  end

  def send_second_followup_email
    @lead = @current_org.leads.where(:id => params[:lead_id]).first
    @contact = @lead.contact
    @mail = send_mail({
                          :subject => "#{@contact.first_name.titleize}, consultation dates now available",
                          :from_name => 'Dr. Constantino Mendieta',
                          :text => 'Thank you for contacting the offices of Dr. Mendieta',
                          :email => @contact.email,
                          :name => "#{@contact.first_name} #{@contact.last_name}",
                          :html => render_to_string('/mail_templates/consultation_upcoming', :layout => false, :locals => {:first_name => @contact.first_name.titleize, :public_token => @contact.public_token}),
                          :from_email => 'concierge@4beauty.net'
                      })
    t = @lead.tasks.new
    t.title = "Qualified - Second Phone Call with #{@contact.first_name}"
    t.description = "Call patient at #{@contact.phone}"
    t.stage = 'inquiry'
    t.lead_id = @lead.id
    t.organization_id = @lead.organization_id
    t.priority = 9
    t.due_date = Time.now + 24.hours
    t.save
    @lead.set(status: BSON::ObjectId.from_string('54e7587832643000030b0000')) # Second Follow Up (Follow Up - Second)
    redirect_to @lead
  end

  def search
    query = params[:term]
    @leads = @current_org.leads.any_of({full_name: /.*#{query}.*/i}, {email: /.*#{query}.*/i}, {phone: /.*#{query}.*/i}).desc('full_name')
  end

  def get_procedure_cost
    interested_in = params[:interested_in]
    procedure_cost = 0
    if interested_in.present? && (procedure = Business::Procedure.where(slug_value: interested_in.underscore.to_sym, organization_id: @current_org.id).first).present?
      procedure_cost = procedure.cost.to_i
    end
    # lead = Business::Lead.find(params[:id])

    respond_to do |format|
      format.json { render json: {procedure_cost: procedure_cost} }
    end
  end

  def move_lead
    @lead = @current_org.leads.find(params[:lead_id])
    @lead.update_attribute(:stage, params[:stage])
    @lead.notes.create(body: "Moved to #{params[:stage]} -- #{params[:reason]}", user_id: @current_account.id)
    @lead.save

    redirect_to request.referrer
  end

  def consult_note
    @lead = @current_org.leads.find(params[:lead_id])

    @lead.update_attribute(:consult_note, params[:consult_note])
    @lead.notes.create(body: "#{params[:consult_note]}", user_id: @current_account.id)
    @task = @lead.tasks.find(params[:task_id])
    @task.set(stage: 'completed')

    if params[:due_date].present?
      t = @lead.tasks.new
      t.title = 'Follow Up with Consult'
      t.communication = 'Follow Up'
      t.description = "Follow Up with #{@lead.name} about their consult."
      t.stage = 'inquiry'
      t.lead_id = @lead.id
      t.organization_id = @lead.organization_id
      t.priority = 9
      t.due_date = Date.strptime(params[:due_date], '%m/%d/%Y')
      t.save
    end

    @lead.save

    redirect_to request.referrer
  end

  def promote_lead

    if @new_stage == 'post_op'
      @lead.update_attribute(:surgery_completed, true)
    end

    @lead.update_attribute(:stage, @new_stage)
    @lead.push(stage_lifecycle: {:stage => @new_stage, :timestamp => Time.now})
    @lead.save

    redirect_to request.referrer
  end

  def get_second_procedure_cost
    interested_in = params[:interested_in]
    procedure_cost = 0
    if interested_in.present? && (procedure = Business::Procedure.where(slug_value: interested_in.underscore.to_sym, organization_id: @current_org.id).first).present?
      procedure_cost = procedure.cost.to_i
    end

    # lead = Business::Lead.find(params[:id])

    respond_to do |format|
      format.json { render json: {procedure_cost: procedure_cost} }
    end
  end

  def complete_task_and_promote_lead

    @lead.update_attribute(:stage, params[:lead_stage])
    @lead.push(stage_lifecycle: {:stage => params[:lead_stage], :timestamp => Time.now})
    @task = Business::Task.where(id: params[:task_id])
    @task.update_attribute(:stage, params[:task_stage])
    @lead.save
    @task.save

    redirect_to request.referrer
  end

  def receptionist_view
    @current_account.set(stages: %w(54b0053b3931620002020000 54cfbf0b3233660003020000 54cfbf2c3233660003060000))
    @current_account.set(task_visibility: 'public')
    @current_account.set(view: 'Receptionist')
    redirect_to business_leads_path
  end

  def coordinator_view
    @current_account.set(stages: %w(54b0053b3931620002020000 54b0053c3931620002030000 54c911623635350003040000 54c911703635350003070000 54cfbf0b3233660003020000 54cfbf2c3233660003060000))
    @current_account.set(task_visibility: 'own')
    @current_account.set(view: 'Sales Coordinator')
    redirect_to business_leads_path
  end

  def mark_leads_cold
    old_leads = Business::Lead.where(stage: 'inquiry').where(:created_at.lt => Date.new(2016, 3, 1)).all
    old_leads.update_all({stage: 'cold'})
    redirect_to business_leads_path
  end

  def consult_log
    @stage = 'booked_consult'
    @field = :consultation_date
    if current_user.roles.include?(current_user.organization.roles.where({name: 'Administrator'}).first.id.to_s)
      @leads = Business::Lead.where(organization: @current_org).where(@field.nin => [nil], stage: @stage).search(params[:search]).consultation_date_range(params[:start_date], params[:end_date]).order(sort_column + " " + sort_direction).paginate(:page => params[:page])
    else
      @leads = Business::Lead.where(organization: @current_org).where(@field.nin => [nil], stage: @stage, user: current_user).search(params[:search]).consultation_date_range(params[:start_date], params[:end_date]).order(sort_column + " " + sort_direction).paginate(:page => params[:page])
    end
  end

  def surgery_log
    @stage = 'booked_surgery'
    if current_user.roles.include?(current_user.organization.roles.where({name: 'Administrator'}).first.id.to_s)
      @leads = @current_org.leads.where(:procedure_date.nin => [nil], stage: @stage).search(params[:search]).procedure_date_range(params[:start_date], params[:end_date]).order(sort_column + " " + sort_direction).paginate(:page => params[:page])
    else
      @leads = @current_org.leads.where(:procedure_date.nin => [nil], stage: @stage, user: current_user).search(params[:search]).procedure_date_range(params[:start_date], params[:end_date]).order(sort_column + " " + sort_direction).paginate(:page => params[:page])
    end
  end

  def book_consult

    @lead = @current_org.leads.find(params[:lead_id])
    begin
      consult_date = Date.strptime(params[:consultation_date], '%m/%d/%Y')
      Business::Consultation.create(
        lead_id: @lead.id,
        cost: params[:consult_cost].to_i,
        date: consult_date
      )
      @lead.update_attribute(:stage, 'booked_consult')
      @lead.save

      if @current_account.is_public? || (['Pre-Op Nurse', 'Post-Op Nurse'] & @current_org.roles.where({:id.in => @current_account.roles}).map(&:name)).present?
        @leads = @current_org.leads.search(params[:search]).coordinator_search(params[:coordinator]).date_range(params[:start_date], params[:end_date]).where(stage: params[:stage_id]).includes(:contact, :user, :tasks, :activities).desc(:created_at)
      else
        @leads = @current_org.leads.where(user: current_user).search(params[:search]).date_range(params[:start_date], params[:end_date]).where(stage: params[:stage_id]).includes(:contact, :user, :tasks, :activities).desc(:created_at)
      end
      @stage_leads_count = @leads.count
      @stage_leads = @leads.page(params[:page])
      @stage = @current_org.stages.where(type: 'lead', stage_id: params[:stage_id]).asc(:position).first
      roles = Business::Role.where(:name.in => ["Surgeon", "Physician Assistant"]).collect(&:id).map(&:to_s)
      @physicians = @current_org.users.where(:roles.in => roles)
      @status = true
    rescue Exception=> @errors
      @status = false
    end
    respond_to do |format|
      format.html { redirect_to request.referrer}
      format.js
    end

  end

  def reschedule_consult
    @lead = @current_org.leads.find(params[:lead_id])
    consult_date = Date.strptime(params[:consultation_date], '%m/%d/%Y')
    @lead.update_attribute(:consultation_date, consult_date)
    @lead.save

    redirect_to request.referrer
  end

  def cancel_consult
    @lead = @current_org.leads.find(params[:lead_id])
    @lead.update_attribute(:cancelled_consult, true)
    @lead.update_attribute(:stage, params[:stage])
    @lead.update_attribute(:no_show, true) if params[:no_show] == 'checked'
    @lead.notes.create(body: "Cancelled Consultation -- #{params[:reason]}", user_id: @current_account.id)
    @lead.save

    redirect_to request.referrer
  end

  def cancel_surgery
    @lead = @current_org.leads.find(params[:lead_id])
    @lead.update_attribute(:cancelled_surgery, true)
    @lead.update_attribute(:stage, params[:stage])
    @lead.notes.create(body: "Cancelled Surgery -- #{params[:reason]}", user_id: @current_account.id)
    @lead.save

    redirect_to request.referrer
  end

  def reschedule_surgery
    @lead = @current_org.leads.find(params[:lead_id])
    procedure_date = Date.strptime(params[:procedure_date], '%m/%d/%Y')
    @lead.update_attribute(:procedure_date, procedure_date)
    @lead.save

    redirect_to request.referrer
  end

  def edit_procedure_info
    @lead = @current_org.leads.find(params[:lead_id])
    procedure_date = Date.strptime(params[:procedure_date], '%m/%d/%Y') if params[:procedure_date].present?

    if params[:procedure].present? && params[:procedure_cost].present?
      @lead.update_attribute(:interested_in, params[:procedure])
      @lead.update_attribute(:procedure_date, procedure_date) if params[:procedure_date].present?
      @lead.update_attribute(:surgery_cost, params[:procedure_cost].to_i)
      @lead.save
      flash[:success] = 'Successfully updated surgery info.'
    else
      flash[:danger] = 'All surgery info is required to update procedure info.'
    end
    redirect_to request.referrer
  end


  def book_surgery
    @lead = @current_org.leads.find(params[:lead_id])
    procedure_date = Date.strptime(params[:procedure_date], '%m/%d/%Y')
    doc = User.find(params[:physician_id]).id
      Business::Surgery.create(
        lead_id: @lead.id,
        cost: params[:procedure_cost].to_i,
        date: procedure_date,
        procedure:  params[:procedure]
      )
     @lead.surgery.update_attribute(:physician_id, doc)

    @lead.update_attribute(:stage, 'booked_surgery')
    @lead.save


      if @current_account.is_public? || (['Pre-Op Nurse', 'Post-Op Nurse'] & @current_org.roles.where({:id.in => @current_account.roles}).map(&:name)).present?
        @leads = @current_org.leads.search(params[:search]).coordinator_search(params[:coordinator]).date_range(params[:start_date], params[:end_date]).where(stage: params[:stage_id]).includes(:contact, :user, :tasks, :activities).desc(:created_at)
      else
        @leads = @current_org.leads.where(user: current_user).search(params[:search]).date_range(params[:start_date], params[:end_date]).where(stage: params[:stage_id]).includes(:contact, :user, :tasks, :activities).desc(:created_at)
      end
      roles = Business::Role.where(:name.in => ["Surgeon", "Physician Assistant"]).collect(&:id).map(&:to_s)
      @physicians = @current_org.users.where(:roles.in => roles)
      @stage_leads_count = @leads.count
      @stage_leads = @leads.page(params[:page])
      @stage = @current_org.stages.where(type: 'lead', stage_id: params[:stage_id]).asc(:position).first
      roles = Business::Role.where(:name.in => ["Surgeon", "Physician Assistant"]).collect(&:id).map(&:to_s)
      @physicians = @current_org.users.where(:roles.in => roles)

    respond_to do |format|
      format.html { redirect_to request.referrer}
      format.js
    end
  end

  def complete_surgery
    @lead = @current_org.leads.find(params[:lead_id])
    @lead.update_attribute(:stage, 'post_op')
    @lead.update_attribute(:surgery_completed, true)
    @lead.notes.create(body: 'Surgery Completed -- Moved to Post Op stage.', user_id: @current_account.id)
    @lead.save

    redirect_to request.referrer
  end

  def send_email
    @lead = @current_org.leads.find(params[:lead_id])
    admin = @current_org.roles.where({name: 'Administrator'}).first
    sender = @current_account.roles.include?(admin.id.to_s) ? @lead.user : @current_account
    begin
      @mail = send_mail({
                            :subject => params[:subject],
                            :from_name => sender.full_name,
                            :email => @lead.email,
                            :name => @lead.name,
                            :html => render_to_string('/mail_templates/direct_email', :layout => false, :locals => {:first_name => @lead.first_name.titleize, :questionnaire_id => @lead.contact.public_token, user_name: sender.full_name, :message => params[:message]}),
                            :from_email => sender.email
                        })
      @lead.notes.create(body: "Email sent to #{@lead.name}. -- #{params[:message]}", user_id: @current_account.id)
      @lead.messages.create(body: render_to_string('/mail_templates/direct_email', :layout => false, :locals => {:first_name => @lead.first_name.titleize, :questionnaire_id => @lead.contact.public_token, user_name: sender.full_name, :message => params[:message]}), type: "email", contact: @lead.contact, user: sender, organization: @lead.organization)

    rescue
      Rails.logger.info 'Failed to send email'
      flash[:error] = 'Failed to send email.'
      @lead.notes.create(body: 'Failed to send email.', user_id: @current_account.id)
    end

    redirect_to request.referrer
  end

  def cold_or_dq_lead
    @lead = @current_org.leads.find(params[:lead_id])
    @lead.update_attribute(:stage, params[:stage])
    @lead.notes.create(body: "Moved to Cold -- #{params[:reason]}", user_id: @current_account.id)
    @lead.save


    redirect_to request.referrer
  end

  # /POST save_treatment
  # Save the coordinates and procedure date of injection procedure of a lead
  def save_treatment
    begin
      treatment = Business::Treatment.new
      treatment.treatment_date = DateTime.strptime(params[:treatment_date], '%m/%d/%Y')
      treatment.name = params[:treatment_name]
      treatment.note = params[:treatment_note]
      treatment.created_by = User.find(params[:user])
      treatment.lead = @lead
      injection_procedures = params[:treatment_procedures].split(',').reject { |tp| tp.blank? }
      injection_coordinates = params[:treatment_coordinates].split('&').reject { |tp| tp.blank? }
      injection_quantity = params[:treatment_quantity].split(',').reject { |tp| tp.blank? }

      injection_procedures.each_with_index do |product, index|
        procedure = @current_org.procedures.where(slug_value: "injectables").first
        ip = Business::InjectionProcedure.new({coordinates: injection_coordinates[index].to_s.split(',').map(&:to_f),
                                               quantity: injection_quantity[index].split(":")[0],
                                               measurement: injection_quantity[index].split(":")[1]
                                               })
        ip.procedure = procedure
        ip.product_id = @current_org.injection_products.find(product).id
        ip.treatment = treatment
        ip.save!

      end
      treatment.save!
      redirect_to business_lead_path(@lead), notice: 'Treatment saved successfully'
    rescue => ex
      p ex.message
      redirect_to business_lead_path(@lead), notice: 'Failed to save treatment.'
    end

  end

  def get_coordinates
    treatment = Business::Treatment.find(params[:id])
    tags = []
    treatment.injection_procedures.includes(:procedure).each do |ip|
      tags << {x: ip.coordinates[0], y: ip.coordinates[1], text: ip.product_name + " " + ip.quantity.to_s + " " + ip.measurement, color: @current_org.injection_products.find(ip.product_id).hex_color}
    end
    render json: {data: tags.to_json.html_safe}, status: :ok
  end

  private

  def set_lead
    @lead = @current_org.leads.find(params[:id])
  end

  def set_promote
    @lead = @current_org.leads.find(params[:lead_id])
    @new_stage = params[:stage]
  end

  def lead_params
    params.require(:business_lead).permit(:auto_communicate, :lifestyle, :events, :kids, :spouse, :nickname, :status, :score, :value, :user, :note, :interested_in, :first_name, :last_name, :email, :phone, :source, :stage, :referral, :address, :city, :state, :zip, :country, :dob, :bra_size, :weight, :height, :gender, :medications, :medical_conditions, :previous_cosmetics_procedure, :previous_cosmetics_year, :surgical_history, :allergies, :smoker, :children, :last_pregnancy_date, :financing, :budget, :planned_surgery_date, :interest_level, :motivation, :expectations, :extra_questions, :appointment_timeframe, :appointment_time_of_day, :appointment_type, :procedure_cost, :procedure_date, :consultation_date, :second_interest, :surgery_cost, :second_procedure_cost, :tasks_attributes => [:stage, :id])
  end

  def sort_column
    if @stage.nil? || @field.nil?
      if @current_account.is_public?
        @current_org.leads.column_names.include?(params[:sort]) ? params[:sort] : 'name'
      else
        @current_org.leads.where(user: current_user).column_names.include?(params[:sort]) ? params[:sort] : 'name'
      end
    else
      @current_org.leads.where(@field.nin => [nil], stage: @stage, user: current_user).column_names.include?(params[:sort]) ? params[:sort] : 'name'
    end
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

end
