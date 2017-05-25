class Api::V1::LeadsController < ApiController
def new
end
def create
	#this is to prevent spam bots
	web = ["http", "https"]
	first = params[:lead][:first_name].scan(URI.regexp).first
	last = params[:lead][:last_name].scan(URI.regexp).first
	redirect_to request.referrer and return if first & web || last & web

	site = Business::Site.where(site_id: params[:site_id]).first
	@current_org = site.organization
	src = site.source

	if @current_org && params[:name].blank? && params[:email].blank?
		@contact = @current_org.contacts.find_or_create_by(email: params[:lead][:email].downcase.strip)
		redirect_to questionnaire_path(@contact.public_token) and return if @contact.leads.count > 0 && 5.minutes.ago < @contact.leads.last.created_at ## Help Prevent multiple leads in one sitting
	    if @contact.new_record?
	      @contact.set({
	          first_name: params[:lead][:first_name].downcase.strip,
	          last_name: params[:lead][:last_name].downcase.strip,
	          phone: params[:lead][:phone],
	          gender: params[:lead][:gender],
	          referral: params[:lead][:referral],
	          # preffered_language: params[:lead][:preffered_language]
	      })
	    end
	    if @contact.last_name.blank?
	    	@contact.last_name = 'None'
	    end
	  @lead = @contact.leads.new(lead_params)
	  @lead.organization_id = @current_org.id
		@lead.email = params[:lead][:email]
		@lead.site = params[:site_id]
		@lead.stage_lifecycle << { :stage => 'inquiry', :timestamp => Time.now }
		@lead.created_by = 'CRM'
		@lead.contact = @contact
		@lead.contact_id = @contact.id
		@lead.source = src

		if params[:injectable] == "true"
			@sales_coordinator_rotation = @lead.organization.settings.where(:setting_id => 'botox_rotation').first
			@sales_coordinator = BSON::ObjectId.from_string(@sales_coordinator_rotation.data[0])
			@lead.set({:stage => 'inquiry', :user => @sales_coordinator})
			@contact.set(account_rep_id: @sales_coordinator)
			@sales_coordinator_rotation.set(:data => @sales_coordinator_rotation.data.rotate())
			@lead.set(spa: true)
		else
			@current_coordinator = @contact.account_rep_id || (@lead.user.nil? ? nil : @lead.user.id)
			@sales_coordinator_rotation = @lead.organization.settings.where(:setting_id => 'coordinator_rotation').first
			@sales_coordinator = @current_coordinator.nil? ? BSON::ObjectId.from_string(@sales_coordinator_rotation.data[0]) : ( active_coordinator(@current_coordinator) ? @current_coordinator : BSON::ObjectId.from_string(@sales_coordinator_rotation.data[0]))
			@lead.set({:stage => 'inquiry', :user => @sales_coordinator})
			@contact.set(account_rep_id: @sales_coordinator)
			@sales_coordinator_rotation.set(:data => @sales_coordinator_rotation.data.rotate())
		end

		if @lead.save! && @contact.save!
			unless params[:injectable] == "true"
        @mail = send_mail({
          :subject=> "Welcome to #{@current_org.company_name}",
          :from_name=> "#{@lead.user.first_name.titleize} and the #{@current_org.company_name} Team",
          :email=> @lead.email,
          :name=> "#{params[:lead][:first_name]} #{params[:lead][:last_name]}",
          :html=> render_to_string('/mail_templates/en/new_lead_general', :layout => false, :locals => {:first_name => @lead.first_name.titleize, :questionnaire_id => @contact.public_token, user_name: @lead.user.first_name.titleize}),
          :from_email=>"#{@lead.user.email}"
        })
        @lead.notes.create(body: "First email sent to #{@lead.first_name}.")
        @lead.activities.create(body: "First email was sent to #{@lead.first_name}.")
        TextWorker.perform_in(1.minute, @lead.id)

				message_setting = @current_org.settings.where(name: "messaging").first.data
	      TextWorker.perform_in(message_setting[0].days, @lead.id)
	      second_email = render_to_string('/mail_templates/en/new_lead_second_contact', :layout => false, :locals => {:first_name => @lead.first_name.titleize, :questionnaire_id => @contact.public_token, user_name: @lead.user.first_name.titleize})
	      EmailWorker.perform_in(message_setting[0].days, @lead.id, second_email)
	      TextWorker.perform_in(message_setting[1].days, @lead.id)
	      third_email = render_to_string('/mail_templates/en/new_lead_third_contact', :layout => false, :locals => {:first_name => @lead.first_name.titleize, :questionnaire_id => @contact.public_token, user_name: @lead.user.first_name.titleize})
	      EmailWorker.perform_in(message_setting[1].days, @lead.id, third_email)

	      MigrateWorker.perform_in(message_setting[2].days, @lead.id)
			end

	    	@lead.activities.create(body: "CRM created the lead from Web Lead Form.")

				begin
					send_mail({
												:subject=> "New Lead was created",
												:from_name=> "Conversion Doctor",
												:text=>"New lead was created.",
												:email=> @lead.user.email,
												:name=> "Conversion Doctor",
												:html=> render_to_string('/mail_templates/new_lead_created', :layout => false, :locals => {:first_name => params[:lead][:first_name], :lead_id => @lead._id, :user => @lead.user.first_name.titleize}),
												:from_email=>"notify@conversiondoctor.com"
										})
				rescue
					Rails.logger.info 'Failed to send email'
				end
			unless params[:injectable] == "true"
				@contact.questionnaire.set(:questionnaire_sent => (@mail[0]["reject_reason"].nil? ? true : false))
			end

	    else
	      raise 500, 'Sorry there was an error'
	    end
	else
		raise 404, 'Not Found'
	end
		respond_to do |format|
			if params[:injectable] == "true"
					format.html {redirect_to request.referrer}
			else
	        format.html {redirect_to questionnaire_path(@contact.public_token)}
			end
	        format.json { render json: { :status => :ok, :message => "Lead Sumbitted"} }
	  end
end
  private

  def lead_params
    params.require('lead').permit(:first_name,:last_name,:email,:phone,:interested_in,:source,:note,:referral,:gender)
  end

end
