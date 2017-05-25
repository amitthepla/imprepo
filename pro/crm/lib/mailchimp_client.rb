module MailchimpClient
  class Mailchimp

    def initialize(api_key)
      @gibbon = Gibbon::Request.new(api_key: api_key)
    end

    def fetch_campaigns
      return [] if @gibbon.api_key.blank?
      begin
        campaigns = @gibbon.campaigns.retrieve
        campaigns['campaigns'].reject { |c| c['settings']['title'].blank? }.sort_by { |c| c['settings']['title'] }.map { |c| [c['settings']['title'], c['id']] }
      rescue => ex
        retry if ex.title.blank?
      end
    end

    def fetch_lists
      return [] if @gibbon.api_key.blank?
      begin
        lists = @gibbon.lists.retrieve
        lists['lists'].reject { |list| list['name'].blank? }.sort_by { |list| list['name'] }.map { |list| [list['name'], list['id']] }
      rescue => ex
        retry if ex.title.blank?
      end
    end

    def create_list(list_opts)
      return false if @gibbon.api_key.blank?
      begin
        req_body = {
            name: list_opts[:name],
            contact: {
                company: list_opts[:company],
                address1: list_opts[:address],
                city: list_opts[:city],
                state: list_opts[:state],
                zip: list_opts[:zip],
                country: list_opts[:country]
            },
            permission_reminder: list_opts[:permission_reminder],
            campaign_defaults: {
                from_name: list_opts[:from_name],
                from_email: list_opts[:from_email],
                subject: list_opts[:subject],
                language: 'en'
            },
            email_type_option: true
        }
        @gibbon.lists.create({body: req_body})
      rescue => ex
        retry if ex.title.blank?
        false
      end
    end

    def update_campaign_list(campaign_id, list_id)
      return false if @gibbon.api_key.blank?
      begin
        @gibbon.campaigns(campaign_id).update({body: {recipients: {list_id: list_id}}})
      rescue => ex
        retry if ex.title.blank?
        false
      end
    end

  end
end
