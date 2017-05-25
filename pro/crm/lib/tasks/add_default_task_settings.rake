namespace :default_records do
  desc "Updating date of birth for search keys"
  task add_default_task_settings: :environment do
  	@current_org = Business::Organization.first
  	@stages = @current_org.stages
  	@lead_stages = @stages.where(type: 'lead')
  	p(@lead_stages)
  	##Find New lead stage id
  	new_stage = @lead_stages.where(:name=>'inquiry').first
  	Business::TaskSetting.create(:name=>"New - First Phone call ", :description => "Call patient at ",:organization=>@current_org,:stage=>new_stage.name,:duration=>28,:auto_create=>true)
  	Business::TaskSetting.create(:name=>"New - Second Phone call", :description => "Call patient at ",:organization=>@current_org,:stage=>new_stage.name,:duration=>28,:auto_create=>true)
  	##Find Qualified lead stage id
  	qualified_stage = @lead_stages.where(:name=>'Inquiry').first
  	Business::TaskSetting.create(:name=>"Qualified - First Phone call", :description => "Call patient at ",:organization=>@current_org,:stage=>qualified_stage.name,:duration=>28,:auto_create=>true)
  	Business::TaskSetting.create(:name=>"Qualified - Second Phone call", :description => "Call patient at ",:organization=>@current_org,:stage=>qualified_stage.name,:duration=>28,:auto_create=>true)
  	Business::TaskSetting.create(:name=>"Qualified - Final Phone call", :description => "Call patient at " ,:organization=>@current_org,:stage=>qualified_stage.name,:duration=>72,:auto_create=>true)
  	##Find Cold lead stage id
  	cold_stage = @lead_stages.where(:name=>'Cold').first
  	Business::TaskSetting.create(:name=>"Qualified - Final Phone call", :description => "Call patient at " ,:organization=>@current_org,:stage=>cold_stage.name,:duration=>72,:auto_create=>true)
  end
end
