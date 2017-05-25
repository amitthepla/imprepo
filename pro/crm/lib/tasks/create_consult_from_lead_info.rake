require File.expand_path(File.dirname(__FILE__) + '../../../config/environment')

namespace :crm do
  desc 'Creates Consultation object from leads consultation data'
  task :create_consults do
    count = 0
    error_count = 0
    Business::Lead.where(:consultation_date.nin => [nil, " ", ""]).each do |lead|

      if lead.consultation_date >= Date.new(2016,3,1) && lead.consultation_date < Date.new(2016,6,1)
        cost = 200
      else
        cost = 100
      end

      begin
        Business::Consultation.create(
          lead_id: lead.id,
          cost: cost,
          date: lead.consultation_date,
          cancelled: lead.cancelled_consult,
          no_show: lead.no_show
        )
        count += 1
      rescue Exception => ex
        error_count += 1
        puts "An error of type #{ex.class} happened, message is #{ex.message}"
      end
    end
    puts "#{count} successful creations"
    puts "#{error_count} unsuccessful creation attempts"
  end
end
