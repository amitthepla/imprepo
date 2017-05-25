require File.expand_path(File.dirname(__FILE__) + '../../../config/environment')

namespace :crm do
  desc 'Task to create sources for each lead'
  task :create_source_for_lead do
    int = SourceType.where(name: "Internet").first
    # word_of_mouth = Business::Source.where(name: "word of mouth").first
    word_of_mouth = Business::Source.where(name: "Word Of Mouth").first
    sources = Business::Organization.first.sources.where(source_type: int).to_a
    leads = Business::Lead.all.where(source: nil)
    count = 0
    error_count=0
    puts "#{leads.count} leads to add sources to"
    leads.each do |lead|
      begin
        if lead.created_by == "CRM" || lead.created_by == "IMPORT"
          lead.source = sources.first
          sources.rotate!
        else
          if count % 2 == 0
            lead.source = sources.first
            sources.rotate!
          else
            lead.source = word_of_mouth
          end
        end
        lead.save
        count += 1
        puts lead.source.name
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
