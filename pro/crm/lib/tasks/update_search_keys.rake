namespace :update_search_keys do
  desc "Updating date of birth for search keys"
  task update_contacts: :environment do
  	o = Business::Organization.first
  	contact = o.contacts
	contact.each do |c|
		if c.date_of_birth.present?
			c.update_attributes(search_keys: [c.first_name.downcase.strip,c.last_name.downcase.strip,(c.phone.nil? ? nil : c.phone.gsub(/\D/, '')),c.email.downcase.strip,(c.date_of_birth.nil? ? nil : c.date_of_birth.strftime("%m/%d/%Y").gsub(/\D/, ''))])
			puts "--------- contact details as follows after update --------------"
			p c.search_keys
			puts "------------ #{c.first_name} contact updated successfully. ------------------"
		end
	end
  end
end
