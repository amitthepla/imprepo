require 'gmail_client'
class SaveLeadNotesWorker
  include Sidekiq::Worker
  include GmailClient
  include Business::EmailHelper

  sidekiq_options :retry => false

  def perform(email_account_id)
    # do something
    @email_account = Business::EmailAccount.find(email_account_id)
    set_up_api

    from_date = (@email_account.last_fetched_on.present?) ? (@email_account.last_fetched_on + 1.second).to_i : Time.now.to_i
    p from_date
    search_options = {q: "after: #{from_date} before: #{Time.now.to_i}"}
    p search_options
    emails, next_page_token = @api_client.fetch_emails_by_label('INBOX', search_options)

    begin
      p "Total filtered messages: #{emails.count}"
      emails.each do |email|
        communicators = get_email_communicators(email)
        from_date = communicators[:received]
        p '****************************************************************************************************'
        p communicators
        contact, staff = get_sender_receiver(communicators[:from], communicators[:to])
        # p contact
        # p staff
        if contact.nil? || staff.nil?
          p 'Emails are not found in database. Skipping current entry...'
        else
          email_body = get_email_content(email)
          store_incoming_emails(communicators[:from], communicators[:to], email_body)
        end
      end
    rescue => ex
      p 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
      p 'An error occured while storing lead notes. Following are error details.'
      p ex.message
      p 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    end
    @email_account.update_attributes({last_fetched_on: Time.at(from_date)})
  end

  def set_up_api
    @email_account.refresh_access_token! if @email_account.access_token_expired?
    @api_client = GmailClient::Gmail.new(@email_account.access_token, @email_account.email)
  end

  def get_sender_receiver(from_address, to_address)
    contact = Business::Contact.where({email: from_address}).first || Business::Contact.where({email: to_address}).first
    staff = User.where({email: from_address}).first || User.where({email: to_address}).first
    return contact, staff
  end

  def store_incoming_emails(from, to, body)
    begin
      p '======================================================='
      p from
      p to

      contact, staff = get_sender_receiver(from, to)
      p '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
      # p contact
      # p staff
      raise 'Mail addresses are not found.' if contact.nil? || staff.nil?
      # This will raise error if the incoming mail is not from a lead
      lead = contact.leads.last
      note = lead.notes.new({body: body, reply_from: (staff.nil? ? 'lead' : (staff.email == to) ? 'lead' : 'staff')})
      note.user = staff if staff && staff.email != to
      note.save!
      p 'Successfully stored email reply in lead notes.'
    rescue => ex
      p '-----------------------------------------------------------------------------------------------------'
      p 'Unable to store lead reply due to following reason.'
      p ex.message
      p '-----------------------------------------------------------------------------------------------------'
    end
  end

end
