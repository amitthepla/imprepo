# require './app/helpers/emails_helper'
# require File.expand_path(File.dirname(__FILE__) + '../../../config/environment')
# include EmailsHelper
# namespace :crm do
#   desc 'Task to import leads that are emailed from realself.'
#   task :create_leads_from_realself_email do
#
#     USERNAME = ENV['GMAIL_USERNAME']
#     PASSWORD = ENV['GMAIL_PWD']
#
#     begin
#       fetcher = EmailFetcher.new(USERNAME, PASSWORD)
#       unread_emails = fetcher.all_unread_emails
#       cnt = 0
#       p "Total Unread messages: #{unread_emails.count}"
#       unread_emails.each do |email|
#         begin
#           from = fetcher.from_address(email)
#           p "Opening email from #{from}..."
#           if from == "expert@realself.com"
#             begin
#               p "Marking message id: #{email.message_id} as read..."
#               email.read!
#               body = fetcher.parse_body(email)
#             rescue => ex
#               p "Error in parsing body: #{ex.message}....Getting raw content."
#               body = email.text_part.body.raw_source.to_s.gsub(/[\n \r]+$/, '')
#             end
#
#             full_name = body.xpath('//td//b[contains(text(), "Name:")]').first.next.content.downcase
#             p "Full Name: #{full_name}"
#
#             name = full_name.split(" ")
#             p "Name Array: #{name}"
#
#             email = body.xpath('//td//b[contains(text(), "Email:")]').first.next.content.downcase
#             p "Email: #{email}"
#
#             if body.xpath('//td//b[contains(text(), "Phone:")]').first
#               phone = body.xpath('//td//b[contains(text(), "Phone:")]').first.next.content.delete("- + () .")
#             else
#               phone = nil
#             end
#             p "Phone: #{phone}"
#
#             if body.xpath('//td//b[contains(text(), "Treatment of interest:")]').first
#               procedure = body.xpath('//td//b[contains(text(), "Treatment of interest:")]').first.next.content.parameterize('_')
#               if procedure == "brazilian_butt_lift"
#                 procedure = "bbl"
#               end
#             else
#               procedure = nil
#             end
#             p "Procedure: #{procedure}"
#
#             if body.xpath('//td//b[contains(text(), "Decision Stage:")]').first
#               decision_stage = body.xpath('//td//b[contains(text(), "Decision Stage:")]').first.next.content
#             else
#               decision_stage = nil
#             end
#             p "Decision Stage: #{decision_stage}"
#
#             if body.xpath('//td//b[contains(text(), "Comments or questions:")]').first
#               comment = body.xpath('//td//b[contains(text(), "Comments or questions:")]').first.next.content
#             else
#               comment = nil
#             end
#             p "Comment: #{comment}"
#
#             p "Got the info, Importing now..."
#
#             current_org = Business::Organization.where(company_name: "4Beauty").first
#
#             if current_org.contacts.where(email: email).first
#              contact = current_org.contacts.where(email: email).first
#             else
#               contact = current_org.contacts.new
#               contact.first_name = name[0]
#               contact.last_name = name[1]
#               contact.phone = phone
#               contact.email = email
#               contact.save
#             end
#
#             p "Created contact.. Now creating lead.."
#
#               lead = contact.leads.new
#               lead.organization_id = current_org.id
#               lead.first_name = name[0]
#               lead.last_name = name[1]
#               lead.phone = phone
#               lead.email = email
#               lead.interested_in = procedure
#               lead.stage = 'inquiry'
#               lead.source = current_org.sources.where(name: "Real Self").first
#               @current_coordintor = contact.account_rep_id || (lead.user.nil? ? nil : lead.user.id)
#               @sales_coordinator_rotation = lead.organization.settings.where(:setting_id => 'coordinator_rotation').first
#               @sales_coordinator = @current_coordintor.nil? ? BSON::ObjectId.from_string(@sales_coordinator_rotation.data[0]) : @current_coordintor
#               lead.user = @sales_coordinator
#               contact.set(account_rep_id: @sales_coordinator)
#               @sales_coordinator_rotation.set(:data => @sales_coordinator_rotation.data.rotate())
#               lead.created_by = "CRM"
#               lead.save
#
#               if decision_stage
#                 note = lead.notes.new
#                 note.body = "Real Self -- Decision Stage:  #{decision_stage}"
#                 note.save
#               end
#
#               if comment
#                 note = lead.notes.new
#                 note.body = "Real Self -- Comment:  #{comment}"
#                 note.save
#               end
#
#               p "Notifying the lead and the coordinator..."
#
#               begin
#                 ApplicationController.new.send_mail({
#                              :subject=> "Welcome to 4Beauty",
#                              :from_name=> "#{lead.user.first_name.titleize} and the 4Beauty Team",
#                              :text=>"Thank you for contacting the offices of Dr. Mendieta",
#                              :email=> lead.email,
#                              :name=> lead.first_name,
#                              :html=> ApplicationController.new.render_to_string('/mail_templates/en/new_lead_general', :layout => false, :locals => {:first_name => lead.first_name.titleize, :questionnaire_id => contact.public_token, user_name: lead.user.first_name.titleize}),
#                              :from_email=>"#{lead.user.email}"
#                           })
#               rescue
#                 Rails.logger.info 'Failed to send email to lead.'
#               end
#
#               begin
#                 ApplicationController.new.send_mail({
#                               :subject=> "New Lead was created",
#                               :from_name=> "4Beauty CRM",
#                               :text=>"New lead was created.",
#                               :email=> lead.user.email,
#                               :name=> "4Beauty Team",
#                               :html=> ApplicationController.new.render_to_string('/mail_templates/new_lead_created', :layout => false, :locals => {:first_name => lead.first_name.titleize, :lead_id => lead._id, :user => lead.user.first_name.titleize}),
#                               :from_email=>"concierge@4beauty.net"
#                           })
#               rescue
#                 Rails.logger.info 'Failed to send email to coordinator.'
#               end
#               p "Configuring automatic messages..."
#               TextWorker.perform_in(1.minute, lead.id)
#
#               TextWorker.perform_in(48.hours, lead.id)
#               second_email = ApplicationController.new.render_to_string('/mail_templates/en/new_lead_second_contact', :layout => false, :locals => {:first_name => lead.first_name.titleize, :questionnaire_id => contact.public_token, user_name: lead.user.first_name.titleize})
#               EmailWorker.perform_in(48.hours, lead.id, second_email)
#               TextWorker.perform_in(216.hours, lead.id)
#               third_email = ApplicationController.new.render_to_string('/mail_templates/en/new_lead_third_contact', :layout => false, :locals => {:first_name => lead.first_name.titleize, :questionnaire_id => contact.public_token, user_name: lead.user.first_name.titleize})
#               EmailWorker.perform_in(216.hours, lead.id, third_email)
#
#               MigrateWorker.perform_in(264.hours, lead.id)
#
#
#           else
#             p 'Emails are not found in database. Skipping current entry...'
#           end
#         rescue => ex
#           cnt += 1
#           p "[#{cnt}] - #{ex.message}. Skipping current entry..."
#         end
#       end
#       p '--------------------------------------------------------------------------------------------'
#       fetcher.logout
#     rescue => ex
#       p 'Failed to connect to gmail.'
#       p ex.message
#       fetcher.logout
#     end
#     p '==========================================================================================================='
#   end
#
#
# end
