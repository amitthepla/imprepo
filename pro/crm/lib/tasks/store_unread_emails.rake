require './app/helpers/gmail_helper'
require File.expand_path(File.dirname(__FILE__) + '../../../config/environment')

namespace :crm do
  desc 'Task to store lead/sales coordinator emails in note section of lead'
  task :store_lead_notes do
    Business::EmailAccount.each do |email_account|
      SaveLeadNotesWorker.perform_async(email_account.id.to_s)
    end
  end
end
