require File.expand_path(File.dirname(__FILE__) + '../../../config/environment')

namespace :crm do
  desc 'clean all phone number'
  task :sanitize_phone do
    count=0
    error_count=0
    Business::Lead.all.each do |lead|
      begin
        phone =  lead.phone.gsub(/[^0-9]/, '').last(10)
        lead.update_attributes(phone: phone)
        count += 1
      rescue Exception => ex
        error_count += 1
        puts "An error of type #{ex.class} happened, message is #{ex.message}"
        puts "check on lead with id #{lead.id}"
      end
    end
    puts "#{count} successful attempts"
    puts "#{error_count} unsuccessful attempts"
  end
end
