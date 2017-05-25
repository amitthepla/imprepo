require './app/helpers/gmail_helper'
require File.expand_path(File.dirname(__FILE__) + '../../../config/environment')

namespace :crm do
  desc 'Task to read call logs from RingCentral API'
  task :read_call_log_custom_date do
      org = Business::Organization.first
      ringcentral = org.ringcentral_account.to_params

      client = RingCentralSdk.new(
          ringcentral[:access_key],
          ringcentral[:secret_key],
          RingCentralSdk::RC_SERVER_PRODUCTION,
          {username: ringcentral[:phone], extension: '', password: ringcentral[:password]}
      )     

      ##getting start and end of month and API query by pagination 
      @from = (ENV['date'].to_date.beginning_of_month).to_time.iso8601
      @to = ENV['date'].to_date.end_of_month.to_time.iso8601

      # @from = (Date.today - 14.days).to_time.iso8601
      # @to = (Date.today - 12.days).to_time.iso8601
      
      ###
      for i in 1..30
        puts "Value of local variable is #{i}"
        puts @from
        puts @to 
        response = client.http.get do |req|
            params = {dateFrom: @from, dateTo: @to, perPage: '1000', page: i }        
            # params = {dateFrom: Date.yesterday.to_time.iso8601, perPage: '1000', page: i}
            req.url '/restapi/v1.0/account/~/call-log', params
        end ##http end

        p '---------------------------------------------- Response Received, Parsing Response --------------------------------------------------'
        if response.status == 200
           if response.body['records'].count == 0
              break
           else
                #org.ringcentral_account.update_attributes({last_fetched: Time.now})

                p "Records Count: #{response.body['records'].count}"
                p '-------------------- Begin --------------------'
                sc, fl, cnt = 0, 0, 0
                response.body['records'].each do |item|
                  cnt += 1
                  from = item['from']['phoneNumber'].last(10) rescue ''
                  to = item['to']['phoneNumber'].last(10) rescue ''

                   # my_logger ||= Logger.new("#{Rails.root}/log/record.log")
                   # my_logger.info item


                  unless from.present? && to.present?
                    fl += 1
                    p "[#{cnt}] Phone numbers are empty. Skipping current entry."
                    next
                  end
                  p "From Number: #{from} and To Number: #{to}"
                  lead = get_lead_from_number(from, to)
                  if lead.nil?
                    fl += 1
                    p "[#{cnt}] Lead not found in database. Skipping current entry."
                    next
                  end
                  begin
                    lead.messages.create!({
                                              body: (item['recording']['contentUri'] rescue nil),
                                              type: 'phone',
                                              contact: lead.contact,
                                              user: lead.user,
                                              organization: lead.organization,
                                              provider: 'ringcentral',
                                              direction: item['direction'],
                                              call_time: Time.parse(item['startTime']),
                                              result: item['result'],
                                              duration: item['duration'],
                                              created_at: Time.parse(item['startTime'])
                                          })
                    sc += 1
                    p "[#{cnt}] Recordings have been saved for - #{lead.name} with id: #{lead.id}"
                  rescue => ex
                    fl += 1
                    p "[#{cnt}] Error occured while saving notes for lead - #{lead.name} with id: #{lead.id}"
                    p ex.message
                    p 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
                  end
                end
                p '-------------------- End --------------------'
                p "Total Records Processed: #{cnt}"
                p "Total Success: #{sc}"
                p "Total Failed: #{fl}"
                sleep(5)
          end
        else          
          p 'Error occured while fetching from ringcentral account.'
        end
    end #end of for
    p '---------------------------------------------- Lead Communication Updated --------------------------------------------------'
  end

  def get_lead_from_number(from, to)
    lead = Business::Lead.where({phone: to}).first || Business::Lead.where({phone: from}).first
    return lead
  end

end
