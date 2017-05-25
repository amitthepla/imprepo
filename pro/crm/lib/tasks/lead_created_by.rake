require File.expand_path(File.dirname(__FILE__) + '../../../config/environment')

namespace :crm do
  desc 'Changes the created by of leads from the name to an id of the user or CRM .'
  task :migrate_created_by do
    count=0
    Business::Lead.all.each do |lead|
      unless lead.created_by.nil?
        first_name = lead.created_by.split(" ")[0].titleize
        user = User.where(first_name: first_name).first
        if !user.nil?
          lead.created_by = user.id
          lead.save
          puts lead.created_by
          count += 1
          puts count
        end
      end
    end
  end
end
