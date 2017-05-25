namespace :mass_email do
  desc "TODO"
  task cold_leads: :environment do
  	o = Business::Organization.first
  	l = o.leads.where(stage: 'unqualified', created_by: 'IMPORT')
  	old = ['reneestef1@aol.com','mary_brutusalexander@aol.com','misskj22@gmail.com','jjessicawyatt14@yahoo.com','gonzalezlupillo989@hotmail.com','mcdonnalwalcott@att.net','jariska08@gmail.com','sexysonia93@gmail.com','kaylaskye011@yahoo.com','renitapenn3658@gmail.com','jazz.powell@ymail.com','nancypdavis27@aol.com','bmckinley09@gmail.com','kimble2001@msn.com','leonela561@hotmail.com','avillanueva@unitedhq.com','jazelle.cozart@gmail.com','jackie_etel@comcast.net','yairimagon@bellsouth.net','tarrahendersonm4@gmail.com','naiomyh@aol.com','irenepchc@yahoo.com','carilyn31@hotmail.com','milafbookings@yahoo.com','mariadiazvalentine@gmail.com','paty3castillo@gmail.com','lansandak@gmail.com','nicolemcd@baptisthealth.net','helenmeneses0625@gmail.com','adrianachicago@gmail.com','marcoslolag@gmail.com','3193715@gmail.com','sheilacampaneria@gmail.com','nubiadowns@hotmail.com','vghabana@yahoo.com','fabie0420@gmail.com','jaymari3rivera@gmail.com','avakianjoe@gmail.com','elainecbold@aol.com','sonyabee@me.com','boobee62@aol.com','m.mendez79@live.com','lagringa1@bellsouth.net','jinnybug@comcast.net','judithdimanche@aol.com','pgksquad@yahoo.com','cheriehuet@sbcglobal.net','lilyjeo@gmail.com','mrscanzj@gmail.com','julia626@hotmail.com','karol4pez@aol.com','irisnzol@gmail.com','michelledirect@gmail.com','lissette.orantes1@gmail.com','odeline5256@yahoo.com','gomezlisandra0710@yahoo.com','mis.sunshine0092@gmail.com','bolore_ingrid@hotmail.com','harmony309@yahoo.com','kbdelamata@hotmail.com','honeybro2br@yahoo.combr','miri_ordaz@yahoo.com','yimarioquendo6060@gmail.com','sarahbarbosa87@gmail.com','silvia.martinez17@yahoo.com','lanenachula2004ny.go@gmail.com','sapphireshell@hotmail.co.uk','georgia.a.dunstan@gmail.com','gcoito.gc@gmail.com','Harry.walker@mac.com','mdelgado8825@gmail.com','ritaland@online.no','amise06@yahoo.com','tahlia.silva@hotmail.com','hadaszwolffe@gmail.com','nmagras@gmail.com','aigner.culpepper@yahoo.com','jamielynnr_09@yahoo.com','bevel.lashonte@gmail.com','ltocara@yahoo.com','ashley_escalante@yahoo.com','roxie116r@gmail.com','nikeshanicole36@gmail.com','wanjiru_mm@yahoo.com','tofeidokyi@gmail.com','shannon.humbles@gmail.com','ycole2012@gmail.com','ypasc002@fiu.edu','willitapahl1@gmail.com','sheliahhunter@gmail.com','pamela.griffith20@gmail.com','corrie_perrigo@yahoo.com','kyndraa.143@gmail.com','getzc@telus.ne','foxyelvia@yahoo.com','natashacutie15@gmail.com','Niyahreeder@ymail.com','nurseshaw2u@gmail.com']
  	puts "Total leads are: #{l.count}"
	require 'mandrill'

	l.each do |lead|
		puts "Current Lead #{lead.first_name} #{lead.last_name} - #{lead.email}"
	    m = Mandrill::API.new
	    if !old.include? lead.email
		    message = {  
		     :subject=> "Hello #{lead.first_name}, This is Dr. Mendieta",  
		     :from_name=> "Dr. Constantino Mendieta",
		     :text=>"Thank you for contacting the offices of Dr. Mendieta",
		     :to=>[  
		       {  
		         :email=> lead.email,
		         :name=> "#{lead.first_name} #{lead.last_name}"
		       }  
		     ],  
		     :html=>ApplicationController.new.render_to_string(:template => '/mail_templates/follow_up_dr_mendieta', :layout => false, :locals => {:first_name => lead.first_name,:questionnaire_id => lead.questionnaire_id}),
		     :from_email=>"concierge@4beauty.net"
		    }  
		    sending = m.messages.send message
		    puts "Mail was sent."
		else
			puts "Mail was already sent."
		end
	end

  end

end
