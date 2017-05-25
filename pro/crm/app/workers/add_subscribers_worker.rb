class AddSubscribersWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(options)
    operations = []
    gibbon = Gibbon::Request.new(api_key: options['api_key'])
    current_org = Business::Organization.find(options['org_id'])
    leads = current_org.leads.search(options['search']).date_range(options['start_date'], options['end_date']).stage_selection(options['stage']).coordinator_search(options['coordinator']).where(:phone.ne => nil)
    p leads.count
    p '------------------------------'

    # Build batch request for adding users to the list.
    leads.each do |lead|
      req = {
          method: 'POST',
          path: "lists/#{options['list_id']}/members",
          body: {email_address: lead.email, status: 'subscribed', merge_fields: {FNAME: lead.first_name, LNAME: lead.last_name}}.to_json
      }
      operations << req
    end

    begin
      resp = gibbon.batches.create(body: {operations: operations})
    rescue
      retry
    end

    # opt = {
    #     api_key: options['api_key'],
    #     list_id: options['list_id'],
    #     campaign_id: options['campaign_id'],
    #     batch_id: resp['id']
    # }
    options.merge!({batch_id: resp['id']})
    SendCampaignWorker.perform_async(options)
  end
end
