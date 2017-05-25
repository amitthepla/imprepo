require 'net/http'
require 'nokogiri'

class SaveEmailTemplateWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(options)
    gibbon = Gibbon::Request.new(api_key: options['api_key'])
    current_org = Business::Organization.find(options['org_id'])
    leads = current_org.leads.search(options['search']).date_range(options['start_date'], options['end_date']).stage_selection(options['stage']).coordinator_search(options['coordinator']).where(:phone.ne => nil)
    p leads.count
    p '------------------------------'

    begin
      campaign = gibbon.campaigns(options['campaign_id']).retrieve
    rescue => ex
      retry if ex.title.blank?
    end

    url = URI.parse(campaign['long_archive_url'])
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) { |http|
      http.request(req)
    }
    doc = Nokogiri::HTML(res.body)
    doc.at_xpath("//div[@id='awesomewrap']").remove if doc.at_xpath("//div[@id='awesomewrap']")
    doc.xpath('//script').remove
    # Add campaign content to lead messages
    leads.each do |lead|
      begin
        lead.messages.create!({
                                  body: doc.to_s,
                                  type: 'template',
                                  contact: lead.contact,
                                  user: lead.user,
                              })
      rescue => ex
        p ex.message
      end

    end
  end
end
