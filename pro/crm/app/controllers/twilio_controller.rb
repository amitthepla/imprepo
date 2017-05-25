class TwilioController < ApplicationController
	skip_before_action :require_login, :get_unread_threads, only: [:receive_text]
	skip_before_action :set_user, :get_unread_threads, only: [:receive_text]
	skip_before_action :set_org, only: [:receive_text]
	respond_to :json

	def receive_text


		phone = params[:From].delete("- + () .")[1..-1]
		lead = Business::Lead.where(phone:  phone).sort_by(&:created_at).last

		lead.notes.create(body: "#{lead.first_name} sent a text message. #{params[:Body]}", user_id: lead.user.id)
		lead.messages.create(body: params[:Body], type: "text", contact: lead.contact, user: lead.user, organization: lead.organization, reply: true)
		Pusher.trigger("private-760c07e3-97b1-4ea7-9271-c8ebe2815599",'message', {:from => lead.name, :subject => 'sent you a text message.'})

	#coordinator email
	begin
		@mail = send_mail({
			:subject=> "Text from #{lead.first_name.titleize}",
			:from_name=> "#{lead.first_name.titleize}'s phone'",
			:email=> lead.user.email,
			:name=> "#{lead.user.first_name}",
			:html=> render_to_string('/mail_templates/new_text_received', :layout => false, :locals => {:first_name => lead.first_name, :user_name => lead.user.first_name , :message => params[:Body], :lead_id => lead.id}),
			:from_email=>"concierge@4beauty.net"
		})
	rescue
		Rails.logger.info 'Failed to send email'
	end

	#nurse email
	if lead.stage == "booked_surgery" || lead.stage == "pre_op"
		begin
			@mail = send_mail({
				:subject=> "Text from #{lead.first_name.titleize}",
				:from_name=> "#{lead.first_name.titleize}'s phone'",
				:email=> "lesslie@4beauty.net",
				:name=> "#{lead.user.first_name}",
				:html=> render_to_string('/mail_templates/new_text_received', :layout => false, :locals => {:first_name => lead.first_name, :user_name => "Lesslie" , :message => params[:Body], :lead_id => lead.id}),
				:from_email=>"concierge@4beauty.net"
			})
		rescue
			Rails.logger.info 'Failed to send email'
		end
	end

  twiml = Twilio::TwiML::Response.new do |r|
		r.Message "Thank you for your response. Your Coordinator will review your message and reach out to you shortly!"
  end


	render text: twiml.text

	end

	def send_text
		lead = Business::Lead.find_by(id: params[:lead_id])
		# account_sid = ENV["TWILIO_ACCOUNT_SID"]
    # auth_token = ENV["TWILIO_AUTH_TOKEN"]

		account_sid = "ACa179c70fe88824db78d48d8b99c8b559"
		auth_token = "786b99978694ea6e7aa72ce6c0533af6"

		client = Twilio::REST::Client.new account_sid, auth_token
		from = lead.user.twilio_phone ? lead.user.twilio_phone : "+13053631680" # Your Twilio number

		message = client.account.messages.create(
			:from => from,
			:to => "+1#{lead.phone}",
			:body => params[:message]
		)

		unless lead.message_id
			lead.message_id = message.sid
		end

		lead.messages.create(body: params[:message], type: "text", contact: lead.contact, user: @current_account, organization: lead.organization)

		lead.notes.create(body: params[:message] , user_id: @current_account.id)
		lead.activities.create(body: params[:message])

		redirect_to request.referrer

	end




end
