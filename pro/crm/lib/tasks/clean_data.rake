require File.expand_path(File.dirname(__FILE__) + '../../../config/environment')
namespace :crm do
  task :clean_db => :environment do
    print "This will clear the entire database.\n"
    print 'Anything other than yes will abort this operation. Continue (yes)? '
    input = STDIN.gets.strip
    if input.to_s.downcase != 'yes'
      abort('Abort.')
    end
    print 'Attempting to clear database...'
    User.destroy_all
    Invite.destroy_all
    Business::Activity.destroy_all
    Business::BankProfile.destroy_all
    Business::BodyProcedure.destroy_all
    Business::EmailAccount.destroy_all
    Business::EmailMessage.destroy_all
    Business::InjectionProcedure.destroy_all
    Business::InjectionProduct.destroy_all
    Business::Casting.destroy_all
    Business::Consultation.destroy_all
    Business::Contact.destroy_all
    Business::Deal.destroy_all
    Business::Email.destroy_all
    Business::Event.destroy_all
    Business::Lead.destroy_all
    Business::LeadPhoto.destroy_all
    Business::LeadStage.destroy_all
    Business::Note.destroy_all
    Business::MailchimpAccount.destroy_all
    Business::Message.destroy_all
    Business::Organization.destroy_all
    Business::PhoneMessage.destroy_all
    Business::Procedure.destroy_all
    Business::Product.destroy_all
    Business::Questionnaire.destroy_all
    Business::Role.destroy_all
    Business::RingcentralAccount.destroy_all
    Business::Scheduler.destroy_all
    Business::Surgery.destroy_all
    Business::Source.destroy_all
    Business::Setting.destroy_all
    Business::Site.destroy_all
    Business::Stage.destroy_all
    Business::Status.destroy_all
    Business::Task.destroy_all
    Business::Treatment.destroy_all
    Business::TaskSetting.destroy_all
    Business::UserTaskSetting.destroy_all
    print "Done.\n"
  end
end
