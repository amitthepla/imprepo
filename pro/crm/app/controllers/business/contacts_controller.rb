class Business::ContactsController < BusinessController
  before_action :set_contact, only: [:show, :edit, :update, :destroy]
  before_action :refresh_access_token, only: :show
  skip_before_action :require_login, :set_user, :set_org, :get_unread_threads, only: [:photo_submission, :request_photos, :source_options, :questionnaire, :questionnaire_submission,
                                                                                      :consultation, :consultation_submission, :store_incoming_emails,
                                                                                      :save_temp_photos, :display_temp_photos, :delete_temp_photos]
  layout 'public', only: [:photo_submission, :request_photos, :questionnaire, :questionnaire_submission, :consultation, :source_options, :save_temp_photos, :display_temp_photos, :delete_temp_photos]

  def index
    @contacts = @current_org.contacts.asc(:first_name).page(params[:page])
  end

  def clone_lead
    lead = @current_org.leads.find(params[:id])
    @contact = lead.contact
    new_lead = lead.clone
    new_lead.created_at = DateTime.now
    new_lead.stage = "inquiry"
    new_lead.stage_lifecycle = []
    new_lead.save

    redirect_to @contact
  end

  def show
    @leads= @contact.leads
    @injection_leads = @leads.where(type: "injection")
    @messages = @contact.messages.order_by(:created_at => 'asc')
  end

  def new
    @contact = @current_org.contacts.new
  end

  def create
    @contact = @current_org.contacts.new(contact_params)
    if @contact.save
      redirect_to @contact
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @contact.update(contact_params)
      redirect_to @contact
    else
      render :edit
    end
  end

  def destroy
    @contact.destroy
    redirect_to business_contacts_path, :notice => "Contact deleted."
  end

  def generate_html_form
    form_content = File.read(File.join(Rails.root, 'html_form.html'))
    doc = Nokogiri::HTML(form_content)
    doc.at_xpath("//input[@id='site_id']")['value'] = params[:site_id]
    content = doc.at('body').children
    render inline: content.to_s
  end

  def questionnaire
    begin
      @contact = Business::Contact.where(:public_token => params[:id]).first
      @questionnaire = @contact.questionnaire
      @questionnaire.set(:questionnaire_viewed => true)
      @contact.leads.last.activities.create(body: 'PT viewed the questionnaire.')
    rescue
      nil
    end
  end

  def send_beauty_profile
    @lead = Business::Lead.find(params[:id])
    @contact = @lead.contact

    @mail = send_mail({
                          :subject => 'Beauty Profile',
                          :from_name => "#{@lead.user.first_name.titleize} and the #{@current_org.company_name.titleize} Team",
                          :email => @lead.email,
                          :name => @lead.name,
                          :html => render_to_string('/mail_templates/resend_beauty_profile', :layout => false, :locals => {:first_name => @lead.first_name.titleize, :questionnaire_id => @contact.public_token, user_name: @lead.user.first_name.titleize, lead_id: @lead.id}),
                          :from_email => "#{@lead.user.email}"
                      })
    @contact.questionnaire.questionnaire_sent = true
    @lead.notes.create(body: "Beauty profile was sent to #{@lead.first_name}.")
    @lead.activities.create(body: "Beauty Profile was sent to #{@lead.first_name}.")
    @lead.save

    respond_to do |format|
      format.js { render layout: false, content_type: 'text/javascript' }
    end

  end

  def send_photo_request
    @lead = Business::Lead.find(params[:id])
    @contact = @lead.contact

    @mail = send_mail({
                          :subject => 'Photo Request',
                          :from_name => "#{@lead.user.first_name.titleize} and the #{@current_org.company_name.titleize} Team",
                          :email => @lead.email,
                          :name => @lead.name,
                          :html => render_to_string('/mail_templates/en/photo_request', :layout => false, :locals => {:first_name => @lead.first_name.titleize, :questionnaire_id => @contact.public_token, user_name: @lead.user.first_name.titleize, lead_id: @lead.id}),
                          :from_email => "#{@lead.user.email}"
                      })
    @lead.photos_requested = true
    @lead.notes.create(body: "Photo Request was sent to #{@lead.first_name}.")
    @lead.activities.create(body: "Photo Request was sent to #{@lead.first_name}.")
    @lead.save

    respond_to do |format|
      format.js { render layout: false, content_type: 'text/javascript' }
    end

  end


  def request_photos
    @lead = Business::Lead.find(params[:id])
    @contact = @lead.contact
  end

  def photo_submission
    @lead = Business::Lead.find(params[:id])
    @contact = @lead.contact
    temp_photos = Business::TempPhoto.where(:token_id => @contact.public_token)
    temp_photos.each do |t|
      @lead.lead_photos.create({photo: t.image.url})
    end
    temp_photos.destroy_all

    @mail = send_mail({
                          :subject => 'Photo Submission',
                          :from_name => "#{@lead.name}",
                          :email => @lead.user.email,
                          :name => @lead.user.full_name,
                          :html => render_to_string('/mail_templates/en/photo_submission', :layout => false, :locals => {:first_name => @lead.first_name, :lead_id => @lead._id, :user => @lead.user.first_name.titleize}),
                          :from_email => "no-reply@conversiondoctor.com"
                      })

    @lead.activities.create(body: 'PT submitted photos.')
    @lead.notes.create(body: 'PT submitted photos.')

    Pusher.trigger("private-#{@lead.user.push_channel_id}", 'message', {:from => @lead.name, :subject => 'has uploaded their photos.'})

    redirect_to thank_you_path(form_type: 'questionnaire', token: @contact.public_token)
  end

  def questionnaire_submission
    @contact = Business::Contact.where(:public_token => params[:questionnaire_token]).first
    @lead = @contact.leads.last
    @lead.source = @lead.organization.sources.where(id: params[:business_contact][:source]).first
    @lead.motivation = params[:business_contact][:questionnaire_attributes][:motivation]
    @lead.planned_surgery_date = params[:business_contact][:questionnaire_attributes][:planned_surgery_date]

    begin
      @contact.date_of_birth = DateTime.strptime(params[:date_of_birth], '%m/%d/%Y')
    rescue
      @lead.activities.create(body: 'Please verify Date of Birth with PT. System experienced an error when updating record.')
      @lead.notes.create(body: 'Please verify Date of Birth with PT. System experienced an error when updating record.')
    end
    @contact.questionnaire.questionnaire_filled = true
    text_data = params
    begin
      @mail = send_mail({
                            :subject => "#{@contact.first_name.titleize}, data when questionnaire is submitted",
                            :from_name => 'CRM::Contact Debugger',
                            :text => text_data,
                            :email => 'sambit11@outlook.com;it@4beauty.net', #max419rockwell@gmail.com;anurag.pattnaik@andolasoft.com;
                            :name => "#{@contact.first_name} #{@contact.last_name}",
                            :html => [params, @contact.errors.full_messages].join('<br><br>'),
                            :from_email => 'it@4beauty.net'
                        })
    rescue
      Rails.logger.info 'Failed to send email'
    end
    if @contact.update_attributes(contact_params)
      @lead.update_attributes(lead_params[:questionnaire_attributes])
      @lead.update_procedure_detail
      @current_coordinator = @contact.account_rep_id || (@lead.user.nil? ? nil : @lead.user.id)

      @sales_coordinator_rotation = @lead.organization.settings.where(:setting_id => 'coordinator_rotation').first
      @sales_coordinator = @current_coordinator.nil? ? BSON::ObjectId.from_string(@sales_coordinator_rotation.data[0]) : (active_coordinator(@current_coordinator) ? @current_coordinator : BSON::ObjectId.from_string(@sales_coordinator_rotation.data[0]))
      @lead.set({:user => @sales_coordinator, :status => BSON::ObjectId.from_string('54e758593264300003090000'), :source => params[:source]})
      @lead.push(stage_lifecycle: {:stage => 'inquiry', :timestamp => Time.now})
      @contact.set(account_rep_id: @sales_coordinator)

      temp_photos = Business::TempPhoto.where(:token_id => @contact.public_token)
      temp_photos.each do |t|
        @lead.lead_photos.create({photo: t.image.url})
      end
      temp_photos.destroy_all

      @lead.activities.create(body: 'PT submitted the questionnaire.')
      @lead.notes.create(body: 'PT submitted the questionnaire.')

      # The following line of code from multiple-practice branch is commented in staging branch. So it remain commented.
      # @sales_coordinator_rotation.set(:data => @sales_coordinator_rotation.data.rotate)

      begin
        @mail = send_mail({
                              :subject => "#{@contact.first_name.titleize}, your consultation is almost here",
                              :from_name => @contact.account_rep.full_name,
                              :text => 'Thank you for contacting the offices of Dr. Mendieta',
                              :email => @contact.email,
                              :name => "#{@contact.first_name} #{@contact.last_name}",
                              :html => render_to_string('/mail_templates/coordinator_intro', :layout => false, :locals => {:first_name => @contact.first_name, :questionnaire_id => @contact.public_token}),
                              :from_email => @contact.account_rep.email
                          })
      rescue
        Rails.logger.info 'Failed to send email'
      end
      @lead.activities.create(body: 'Coordinator Intro e-mail was sent.')
      @lead.notes.create(body: 'Coordinator Intro e-mail was sent.')
      @lead.update_attribute(:stage, 'inquiry')

      Pusher.trigger("private-#{@lead.user.push_channel_id}", 'message', {:from => @lead.name, :subject => 'submitted thier Beauty Profile.'})

      respond_to do |format|
        format.html { redirect_to thank_you_path(form_type: 'questionnaire', token: @contact.public_token) }
        format.json { render json: {:status => :ok, :message => 'Lead Updated'} }
      end
    else
      render :questionnaire
    end
  end

  def store_incoming_emails
    begin
      params_hash = params
      from_address = params_hash['From'].to_s.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i)[0]
      to_address = params_hash['To'].to_s.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i)[0]
      staff = User.where({email: from_address}).first

      begin
        # parse the DOM tree using Nokogiri
        doc = Nokogiri::HTML(params_hash['body-html'])

        # fetch the value of token using xpath
        public_token = doc.at_xpath("//input[@id='questionnaire_id']")['value']
        contact = Business::Contact.find_by({public_token: public_token})
      rescue
        # If token is not available
        contact, staff = get_sender_receiver(from_address, to_address)
      end

      attachment_count = params_hash['attachment-count'] || 0
      replied_body = params_hash['stripped-html']

      # This will raise error if the incoming mail is not from a lead
      lead = contact.leads.last
      note = lead.notes.new({body: replied_body, reply_from: (staff.nil? ? 'lead' : (staff.email == to_address) ? 'lead' : 'staff'), attachment_count: attachment_count})
      note.user = staff if staff && staff.email != to_address
      note.save!
      render nothing: true, status: :ok
    rescue
      render json: {message: 'Unable to store lead reply.'}, status: :internal_server_error
    end
  end

  def consultation
    @contact = Business::Contact.where(:public_token => params[:id]).first
    @questionnaire = @contact.questionnaire
    @questionnaire.set(:consultation_viewed => true)
    @contact.leads.last.activities.create(body: 'PT viewed the consultation form.')
    redirect_to thank_you_path(form_type: 'consultation', token: @contact.public_token) if @questionnaire.consultation_filled
  end

  def consultation_submission
    @contact = Business::Contact.where(:public_token => params[:questionnaire_token]).first
    @contact.date_of_birth = DateTime.strptime(params[:business_contact][:date_of_birth], '%d/%m/%Y') if params[:business_contact][:date_of_birth].present?
    @contact.questionnaire.consultation_filled = true
    @lead = @contact.leads.last
    if @contact.update_attributes(contact_params)
      @lead.activities.create(body: 'PT submitted the consultation form.')
      @lead.notes.create(body: 'PT submitted the consultation form.')
      send_mail({
                    :subject => "[#{@contact.first_name}] - Consult Packet was filled.",
                    :from_name => '4Beauty CRM',
                    :text => 'Consult Packet was filled.',
                    :email => 'colleen@4beauty.net',
                    :name => "#{@current_org.company_name.titleize} Team",
                    :html => render_to_string('/mail_templates/new_consult_packet_filled', :layout => false, :locals => {:first_name => @contact.first_name, :lead_id => @lead._id}),
                    :from_email => 'concierge@4beauty.net'
                })
      respond_to do |format|
        format.html { redirect_to thank_you_path(form_type: 'consultation', token: @contact.public_token) }
        format.json { render json: {:status => :ok, :message => 'Lead Updated'} }
      end
    end
  end

  def calendar_request_submission
    @contact = Business::Contact.where(public_token: params[:token]).first
    @lead = @contact.leads.last
    if @lead
      @lead.set({:requested_appointment_day => Date.parse(params[:selected_date]), :requested_appointment_timeframe => params[:selected_timeframe]})
      @date = Date.parse(params[:selected_date]).strftime('%m/%d/%Y')
      @lead.activities.create(body: "PT requested a consultation for #{@date} in the #{params[:selected_timeframe]}.")
      @lead.notes.create(body: "PT requested a consultation for #{@date} in the #{params[:selected_timeframe]}.")
      redirect_to thank_you_path
    else
      redirect_to calendar_path(token: params[:token])
    end
  end

  def consult_packet
    @contact = @current_org.contacts.find(params[:contact_id])
    respond_to do |format|
      format.html {}
      format.pdf {
        render :pdf => 'show', :header => {:font_size => '8'}
      }
    end
  end

  def send_consult_packet
    @contact = @current_org.contacts.find(params[:contact_id])
    @lead = @contact.leads.last
    @mail = send_mail({
                          :subject => 'Your consultation forms',
                          :from_name => @contact.account_rep_full_name,
                          :text => 'Thank you for contacting the offices of Dr. Mendieta',
                          :email => @contact.email,
                          :name => "#{@contact.first_name} #{@contact.last_name}",
                          :html => render_to_string('/mail_templates/consultation_forms', :layout => false, :locals => {:first_name => @contact.first_name, :consultation_id => @contact.public_token}),
                          :from_email => 'concierge@4beauty.net'
                      })
    @lead.activities.create(body: 'Consultation Forms e-mail was sent.')
    @lead.notes.create(body: 'Consultation Forms e-mail was sent.')
  end

  def search
    @contacts = @current_org.contacts.where(search_keys: /^#{params[:term]}/i)
  end

  # Get available source options for a given source type.
  #
  def source_options
    contact = Business::Contact.find(params[:contact_id])
    content = {}
    sources = SourceType.find(params[:id]).sources.where(organization_id: contact.organization.id).pick_from_active_sources
    sources.each { |src| content[src.id.to_s] = src.name }
    render json: content
  end

  # save temp photos in database
  def save_temp_photos
    begin
      params[:temp_photo][:image].each do |tmp|
        Business::TempPhoto.create(:image => tmp[1], :token_id => params[:temp_photo][:questionnaire_token])
      end
      render json: {status: 'success'}
    rescue
      render json: {status: 'error'}
    end
  end

  # Display all temp photos based on token
  def display_temp_photos
    @temp_photos = Business::TempPhoto.where(:token_id => params[:token])
    render :partial => 'temp_photos'
  end

  # Delete specific temp photo
  def delete_temp_photos
    begin
      temp_photo = Business::TempPhoto.find(params[:id])
      temp_photo.destroy
      render json: {status: 'success'}
    rescue
      render json: {status: 'error'}
    end
  end

  def campaign_template
    msg = Business::Message.find(params[:id])
    render html: msg.body.html_safe
  end

  private

  def set_contact
    @contact = @current_org.contacts.find(params[:id])
  end

  def refresh_access_token
    @current_org.ringcentral_account.refresh_token! if @current_org.ringcentral_account.present? && @current_org.ringcentral_account.access_token_expired?
  end

  def contact_params
    params.require(:business_contact).permit(:first_name, :last_name, :email, :phone, :address, :city, :state, :zip,
                                             :date_of_birth, :alt_phone, :alt_email, :driver_license_number, :driver_license_state,
                                             :bra_size, :dress_size, :weight, :height, :gender, :employer, :occupation, :business_phone,
                                             :emergency_contact_first_name, :emergency_contact_last_name, :emergency_contact_phone,
                                             :emergency_contact_relationship, :date_of_birth, :recieve_marketing, :preffered_contact_method,
                                             :preffered_language, :marital_status,
                                             :questionnaire_attributes => [:id, :status, :score, :value, :user, :note, :interested_in, :first_name,
                                                                           :last_name, :email, :phone, :source, :stage, :referral, :address, :city,
                                                                           :state, :zip, :country, :bra_size, :weight, :height, :gender, :medications,
                                                                           :medical_conditions, :surgical_history, :allergies, :smoker, :children,
                                                                           :last_pregnancy_date, :financing, :budget, :planned_surgery_date,
                                                                           :interest_level, :motivation, :expectations, :extra_questions,
                                                                           :appointment_timeframe, :appointment_time_of_day, :appointment_type,
                                                                           :recreational_drug_use, :alcholic_use, :caffine_use, :smoke_use,
                                                                           :history_of_breast_cancer, :interested_in, :second_interest,
                                                                           :cardiologist_visit, :cardiologist_physician,
                                                                           :cardiologist_ekg, :anesthesia_history, :silicon_injection_type,
                                                                           :silicon_injection_amount, :silicon_injection_date, :silicon_injection_qty,
                                                                           :silicon_injection_problem_start, :silicon_injection_problem_years,
                                                                           :silicon_injection_treament, :silicon_injection_symptoms])
  end

  def lead_params
    params.require(:business_contact).permit(:interested_in, :second_interest, :first_name, :last_name, :email, :phone, :address, :city, :state, :zip,
                                             :date_of_birth, :bra_size, :dress_size, :weight, :height, :gender)
  end

  def get_sender_receiver(from_address, to_address)
    contact = Business::Contact.where({email: from_address}).first || Business::Contact.where({email: to_address}).first
    staff = User.where({email: from_address}).first || User.where({email: to_address}).first
    return contact, staff
  end

end
