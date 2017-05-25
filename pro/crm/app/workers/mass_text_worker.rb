class MassTextWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(options)
    account_sid = ENV["TWILIO_ACCOUNT_SID"]
    auth_token = ENV["TWILIO_AUTH_TOKEN"]

    client = Twilio::REST::Client.new account_sid, auth_token
    from = "+13053631680" # Your Twilio number
    org = Business::Organization.find(options['org_id'])
    leads = org.leads.find(options['leads'])
    leads.each do |lead|

      begin
        if options[:media_url].present?
          message = client.account.messages.create(
              :from => from,
              :to => "+1#{lead.phone}",
              :body => options['body'],
              :media_url => options['media_url']
          )
        else
          message = client.account.messages.create(
              :from => from,
              :to => "+1#{lead.phone}",
              :body => options['body']
          )
        end

        lead.messages.create(body: options['body'], type: "text", contact: lead.contact, user: lead.user, organization: org.id)
        lead.notes.create(body: options['body'], user_id: lead.user.id)
        lead.activities.create(body: options['body'])

      rescue Exception => reason
        lead.notes.create(body: "Unable to send mass text. #{reason}", user_id: lead.user.id)
      end
    end
  end
end
