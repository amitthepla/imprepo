require './app/helpers/gmail_helper'
require File.expand_path(File.dirname(__FILE__) + '../../../config/environment')

namespace :crm do
  desc 'Task to store lead/sales coordinator emails in note section of lead'
  task :store_lead_full_name do
    Business::Lead.all.each{|user| user.update_attributes({full_name: user.name})}
  end
end
