require File.expand_path(File.dirname(__FILE__) + '../../../config/environment')
namespace :crm do
  task :create_site_admin => :environment do
    attributes = {
        first_name: 'Super',
        last_name: 'Admin',
        email: 'superadmin@theconversiondoctor.com',
        username: 'super_admin',
        password: 'SuperAdmin@12345$',
        password_confirmation: 'SuperAdmin@12345$',
        is_super_admin: true,
        site_admin: true,
        task_visibility: 'public'
    }
    user = User.new(attributes)
    if user.valid?
      user.save
      print "Site admin created.\n"
    else
      print "Following errors prevented to create site admin.\n"
      user.errors.full_messages.each do |msg|
        print "#{msg}.\n"
      end
    end

  end
end