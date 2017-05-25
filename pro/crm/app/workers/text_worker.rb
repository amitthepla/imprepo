class TextWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(lead_id)
    if Business::Lead.where(id: lead_id).first.present?
      puts lead_id
      lead = Business::Lead.where(id: lead_id).first

      account_sid = ENV["TWILIO_ACCOUNT_SID"]
      auth_token = ENV["TWILIO_AUTH_TOKEN"]
      client = Twilio::REST::Client.new account_sid, auth_token

      from = lead.user.twilio_phone ? lead.user.twilio_phone : "+13053631680" # Your Twilio number

      if lead.stage == 'inquiry' && lead.auto_communicate

        if lead.activities.where(body: "First text message was sent to new lead.").count == 0 && lead.activities.where(body: "Coordinator opted out of intro.").count == 0

                            client.account.messages.create(
                              :from => from,
                              :to => "+1#{lead.phone}",
                              :body => "Hello #{lead.first_name.titleize},\n\nThis is #{lead.user.first_name.titleize} with Dr. Mendieta & 4Beauty.\n\nThank you for contacting us to schedule your consultation.\n\nThis is my direct line, #{from}, if you have any questions do not hesitate to call me - talk soon!\n\n- #{lead.user.first_name.titleize} & the #{@current_org.company_name.titleize} Team"
                            )
                            lead.notes.create(body: "Intro text message sent to #{lead.first_name}.")
                            lead.activities.create(body: "First text message was sent to new lead.")
                            lead.messages.create(body: "Hello #{lead.first_name.titleize},\n\nThis is #{lead.user.first_name.titleize} with Dr. Mendieta & 4Beauty.\n\nThank you for contacting us to schedule your consultation.\n\nThis is my direct line, #{from}, if you have any questions do not hesitate to call me - talk soon!\n\n- #{lead.user.first_name.titleize} & the #{@current_org.company_name.titleize} Team", type: "text", contact: lead.contact, user: lead.user, organization: lead.organization)


        elsif (lead.activities.where(body: "First text message was sent to new lead.").count >= 1 || lead.activities.where(body: "Coordinator opted out of intro.").count == 1) && lead.activities.where(body: "Second text message was sent to new lead.").count == 0

                            client.account.messages.create(
                              :from => from,
                              :to => "+1#{lead.phone}",
                              :body => "Hi #{lead.first_name.titleize} -\n\nThis is #{lead.user.first_name.titleize}. \n\nWe have some amazing Before and Afters on the website as well as so much more info.\n\nhttp://www.buttsbymendieta.com/procedure/female-fat-transfer-small-med-build/"
                            )
                            lead.notes.create(body: "Second text message sent to #{lead.first_name} after 48 hours.")
                            lead.activities.create(body: "Second text message was sent to new lead.")
                            lead.messages.create(body: "Hi #{lead.first_name.titleize} -\n\nThis is #{lead.user.first_name.titleize}. \n\nWe have some amazing Before and Afters on the website as well as so much more info.\n\nhttp://www.buttsbymendieta.com/procedure/female-fat-transfer-small-med-build/", type: "text", contact: lead.contact, user: lead.user, organization: lead.organization)



        elsif (lead.activities.where(body: "First text message was sent to new lead.").count >= 1 || lead.activities.where(body: "Coordinator opted out of intro.").count == 1) && lead.activities.where(body: "Second text message was sent to new lead.").count >= 1 && lead.activities.where(body: "Third text message was sent to new lead.").count == 0

                            client.account.messages.create(
                              :from => from,
                              :to => "+1#{lead.phone}",
                              :body => "Hi #{lead.first_name.titleize},\n\nThis is #{lead.user.first_name.titleize}. \n\nHere’s a sneak peak at Dr. Mendieta in the operating room!\n\nhttps://www.instagram.com/p/BEgE1fGwsJe/?taken-by=doctormendieta"
                            )
                            lead.notes.create(body: "Third text message sent to #{lead.first_name} after 96 hours.")
                            lead.activities.create(body: "Third text message was sent to new lead.")
                            lead.messages.create(body: "Hi #{lead.first_name.titleize},\n\nThis is #{lead.user.first_name.titleize}. \n\nHere’s a sneak peak at Dr. Mendieta in the operating room!\n\nhttps://www.instagram.com/p/BEgE1fGwsJe/?taken-by=doctormendieta", type: "text", contact: lead.contact, user: lead.user, organization: lead.organization)

        end
      end
    end
  end
end
