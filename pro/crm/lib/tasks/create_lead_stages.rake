namespace :crm do
  desc "create lead stages"
  task create_lead_stages: :environment do
  	leads = Business::Lead.all
  	leads.each do |lead|
  		puts lead.id
  		lead.stage_lifecycle.each do |lifecycle|
  			puts lifecycle
  			lead.lead_stages.create(:stage=>lifecycle[:stage].present? ? lifecycle[:stage] : lifecycle["name"].present? ? lifecycle["name"] : lead.stage,:timestamp=>lifecycle[:timestamp].present? ? lifecycle[:timestamp] : lifecycle["timestamp"])
  		end
  	end
  end
end
