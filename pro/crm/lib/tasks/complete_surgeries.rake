require File.expand_path(File.dirname(__FILE__) + '../../../config/environment')

namespace :crm do
  desc 'Complete surgeries of leads in "booked_surgery" stage and procedure date has past.'
  task :complete_surgeries do
    count=0
    error_count=0
    Business::Lead.all.where(stage: "booked_surgery").each do |lead|
      begin
        if lead.surgery.date < DateTime.now && !lead.surgery.cancelled
          lead.surgery.update_attributes({completed: true})
          lead.update_attributes({stage: "post_op"})
          count = count + 1
        end
      rescue Exception => ex
        error_count += 1
        puts "An error of type #{ex.class} happened, message is #{ex.message}"
        puts "check on lead with id #{lead.id}"
      end
    end
    puts "#{count} successful creations"
    puts "#{error_count} unsuccessful creation attempts"
  end
end
