namespace :destroy do  
	 ##Delete old created records
	 task :old_records => :environment do 
	 	puts "-------> Deleting<-------------"
	 	Content.where("created_at < ?", Time.now).delete_all
	 end
end