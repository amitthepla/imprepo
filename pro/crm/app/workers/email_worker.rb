class EmailWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(lead_id, email)
    if Business::Lead.where(id: lead_id).first.present?
      lead = Business::Lead.find(lead_id)
      require 'mandrill'
      m = Mandrill::API.new

      if lead.stage == 'inquiry' && lead.auto_communicate

        if (lead.activities.where(body: "First email was sent to #{lead.first_name}.").count >= 1 || lead.activities.where(body: "Coordinator opted out of intro.").count >= 1) && lead.activities.where(body: "Second email was sent to #{lead.first_name}.").count == 0

                message = {
                  :subject=> "Welcome",
                  :from_name=> "#{lead.user.first_name.titleize} and the #{lead.organization.company_name.titleize} Team",
                  :text=>"Thank you #{lead.organization.company_name.titleize}",
                  :to=>[
                    {
                      :email=> "#{lead.email}",
                      :name=> "#{lead.first_name.titleize}",
                    }
                  ],
                  :html=> email,
                  :from_email=>"#{lead.user.email}"
                }
                sending = m.messages.send message

                lead.messages.create(body: email, type: "email", contact: lead.contact, user: lead.user, organization: lead.organization)
                lead.notes.create(body: "Second email sent to #{lead.first_name} after 48 hours.")
                lead.activities.create(body: "Second email was sent to #{lead.first_name}.")

        elsif (lead.activities.where(body: "First email was sent to #{lead.first_name}.").count >= 1 || lead.activities.where(body: "Coordinator opted out of intro.").count >= 1) && lead.activities.where(body: "Second email was sent to #{lead.first_name}.").count >= 1 && lead.activities.where(body: "Third email was sent to #{lead.first_name}.").count == 0

                message = {
                  :subject=> "Welcome",
                  :from_name=> "#{lead.user.first_name.titleize} and the #{lead.organization.company_name.titleize} Team",
                  :text=>"Thank you #{lead.organization.company_name.titleize}",
                  :to=>[
                    {
                      :email=> "#{lead.email}",
                      :name=> "#{lead.first_name.titleize}",
                    }
                  ],
                  :html=> email,
                  :from_email=>"#{lead.user.email}"
                }
                sending = m.messages.send message

                lead.messages.create(body: email, type: "email", contact: lead.contact, user: lead.user, organization: lead.organization)
                lead.notes.create(body: "Third email sent to #{lead.first_name} after 96 hours.")
                lead.activities.create(body: "Third email was sent to #{lead.first_name}.")

        end
      end
    end
  end
end
