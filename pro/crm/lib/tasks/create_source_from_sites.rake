require File.expand_path(File.dirname(__FILE__) + '../../../config/environment')

namespace :crm do
  desc 'Task to create sources for each site'
  task :create_source_from_site do
    Business::Site.all.each do |site|
      org = site.organization
      type = SourceType.where(name: 'Internet').first
      org.sources.create(name: site.name, source_type: type, cost: 0 )
    end
  end
end
