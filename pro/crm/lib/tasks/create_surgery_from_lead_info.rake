require File.expand_path(File.dirname(__FILE__) + '../../../config/environment')

namespace :crm do
  desc 'Creates Surgery object from leads procedure data'
  task :create_surgeries do
    count = 0
    error_count = 0
    doc = User.where(first_name: "Constantino").first
    Business::Lead.where(:stage.nin => ['cold','inquiry','disqualified_leads', 'disqualified','archive','temp_stage', 'booked_consult', '', ' ']).each do |lead|
      begin
        Business::Surgery.create(
          lead_id: lead.id,
          cost: lead.surgery_cost,
          date: lead.procedure_date,
          completed: lead.surgery_completed,
          cancelled: lead.cancelled_surgery,
          procedure: lead.interested_in,
          physician_id: doc
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
