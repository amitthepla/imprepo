require './app/helpers/gmail_helper'
# require File.expand_path(File.dirname(__FILE__) + '../../../config/environment')

# TODO: Only admin can access it.
module Business
  class ImportController < BusinessController
    include GmailHelper

    def index
      lead = @current_org.leads.where(referral: 'Optical').last
      @last_imported_record = lead.present? ? lead.created_at.in_time_zone('Eastern Time (US & Canada)').strftime('%m/%d/%Y  %I:%M%p') : 'N/A'
    end

    def parse
      @file = params[:file]
      @leads = SmarterCSV.process(@file.tempfile, {:col_sep => ',', :row_sep => :auto})

      @procedures = @current_org.procedures
      @coordinators = User.where(organization: @current_org).where(:role_id => '54c155e56665380003020000')
      if User.where(:role_id => '56f2d9ff495473069a200000').first
        @coordinators.push(User.where(:role_id => '56f2d9ff495473069a200000').first)
      end
    end

    def import_lead
      @total_records_imported = 0
      @errors = ''

      params['imported_leads'].each do |lead|
        data = lead[1]
        if data[:email].present? || data[:phone].present?
          @email = data[:email].blank? ? data[:phone] : data[:email]
          @contact = @current_org.contacts.find_or_create_by(email: @email.downcase.strip)

          if @contact.new_record?
            @contact.set({
                             first_name: data[:first_name].downcase.strip,
                             last_name: data[:last_name].downcase.strip,
                             phone: data[:phone].downcase.strip,
                             referral: data[:marketing_source],
                         })
          end

          @contact.set({
                           address: data[:address].downcase.strip,
                           city: data[:city].downcase.strip,
                           state: data[:state].downcase.strip,
                           zip: data[:zip],
                       })

          if @contact.last_name.blank?
            @contact.last_name = 'none'
          end

          @lead = @contact.leads.new({
                                         first_name: data[:first_name].downcase.strip,
                                         last_name: data[:last_name].downcase.strip,
                                         phone: data[:phone].downcase.strip,
                                         referral: data[:source],
                                         email: @email.downcase.strip,
                                         interested_in: data[:call_type].present? ? data[:call_type] : 'other',
                                         source: data[:marketing_source],
                                         organization_id: @current_org.id,
                                         created_by: 'Import',
                                         opticall: true,
                                         stage: 'importing',
                                     })

          if data[:coordinator].present?
            @contact.account_rep_id = data[:coordinator]
          end
            @current_coordinator = @contact.account_rep_id || (@lead.user.nil? ? nil : @lead.user.id)
            @sales_coordinator_rotation = @lead.organization.settings.where(:setting_id => 'coordinator_rotation').first
            @sales_coordinator = @current_coordinator.nil? ? BSON::ObjectId.from_string(@sales_coordinator_rotation.data[0]) : ( active_coordinator(@current_coordinator) ? @current_coordinator : BSON::ObjectId.from_string(@sales_coordinator_rotation.data[0]))
            @lead.set(:user => @sales_coordinator)
            @contact.set(account_rep_id: @sales_coordinator)
            @sales_coordinator_rotation.set(:data => @sales_coordinator_rotation.data.rotate())


          @lead.email = @email
          @lead.save

          if data[:consult_date].present?
            date = data[:consult_date].split("-")
            @lead.set(consultation_date: Date.new(date[2].to_i, date[0].to_i, date[1].to_i))
            @lead.update_attribute(:stage, 'booked_consult')
            @lead.stage_lifecycle << {:stage => 'booked_consult', :timestamp => Time.now}
          elsif data[:stage].present? && data[:stage] != 'booked_consult'
            @lead.update_attribute(:stage, data[:stage])
            @lead.stage_lifecycle << {:stage => data[:stage], :timestamp => Time.now}
          else
            @lead.update_attribute(:stage, 'inquiry')
            @lead.stage_lifecycle << {:stage => 'inquiry', :timestamp => Time.now}
          end

          @lead.contact = @contact
          @lead.contact_id = @contact.id

          begin
            @contact.date_of_birth = DateTime.strptime(data[:date_of_birth][0, 10].gsub('-', '/'), '%m/%d/%Y') if !data[:date_of_birth].blank? && data[:date_of_birth] != 'N/A'
          rescue
            @dob_error_note = @lead.notes.new(body: 'Please verify Date of Birth with PT.')
          end

          if @lead.save! && @contact.save!

            unless @contact.email.match(/\@/)
              @lead.notes.create(body: 'Please verify e-mail address with PT.')
            end

            if @dob_error_note
              @dob_error_note.save
            end
            message_setting = @current_org.settings.where(name: 'messaging').first.data
            @lead.activities.create(body: 'CRM Imported Lead from Opticall')
            @lead.notes.create(body: 'CRM Imported Lead from Opticall')
            unless @contact.questionnaire.questionnaire_sent
              if data[:email].present?
                @mail = send_mail({
                                      :subject => 'Welcome to 4Beauty',
                                      :from_name => "#{@lead.user.first_name.titleize} and the #{@current_org.company_name.titleize} Team",
                                      :text => 'Thank you for contacting the offices of Dr. Mendieta',
                                      :email => data[:email],
                                      :name => "#{@lead.name}",
                                      :html => render_to_string('/mail_templates/en/new_lead_general', :layout => false, :locals => {:first_name => @lead.first_name.titleize, :questionnaire_id => @contact.public_token, user_name: @lead.user.first_name.titleize}),
                                      :from_email => "#{@lead.user.email}"
                                  })
                @contact.questionnaire.set(:questionnaire_sent => (@mail[0]['reject_reason'].nil? ? true : false))
                @lead.notes.create(body: "First email sent to #{@lead.first_name}.")
                @lead.activities.create(body: "First email was sent to #{@lead.first_name}.")

                second_email = render_to_string('/mail_templates/en/new_lead_second_contact', :layout => false, :locals => {:first_name => @lead.first_name.titleize, :questionnaire_id => @contact.public_token, user_name: @lead.user.first_name.titleize})
                EmailWorker.perform_in(message_setting[0].days, @lead.id, second_email)
                third_email = render_to_string('/mail_templates/en/new_lead_third_contact', :layout => false, :locals => {:first_name => @lead.first_name.titleize, :questionnaire_id => @contact.public_token, user_name: @lead.user.first_name.titleize})
                EmailWorker.perform_in(message_setting[1].days, @lead.id, third_email)
              end
              if data[:phone].present?

                TextWorker.perform_in(1.minute, @lead.id)

                TextWorker.perform_in(message_setting[0].days, @lead.id)
                TextWorker.perform_in(message_setting[1].days, @lead.id)

              end

              MigrateWorker.perform_in(message_setting[2].days, @lead.id)

              begin
                send_mail({
                              :subject => 'New Lead was created',
                              :from_name => '4Beauty CRM',
                              :text => 'New lead was created.',
                              :email => @lead.user.email,
                              :name => "#{@current_org.company_name.titleize} Team",
                              :html => render_to_string('/mail_templates/new_lead_created', :layout => false, :locals => {:first_name => @lead.first_name.titleize, :lead_id => @lead._id, :user => @lead.user.first_name.titleize}),
                              :from_email => 'concierge@4beauty.net'
                          })
              rescue
                Rails.logger.info 'Failed to send email'
              end

            end
          end

          @lead.notes.create(body: data[:note])
          @total_records_imported += 1
        else
          @errors += "\n#{data[:first_name].strip} #{data[:last_name].strip}"
        end
      end

      respond_to do |format|
        format.html { redirect_to business_leads_path }
        format.json { render json: {:status => :ok, :message => "Total Records Imported: #{@total_records_imported}", :errors => "#{@errors}"} }
      end
    end


    def import_realself_emails
      username = ENV['SALES_USERNAME']
      password = ENV['SALES_PASSWORD']

      begin
        fetcher = EmailFetcher.new(username, password)
        unread_emails = fetcher.all_unread_emails
        cnt = 0
        impt = 0
        leads = {names: []}
        unread_emails.each do |email|

          begin
            from = fetcher.from_address(email)
            if from == 'expert@realself.com'
              begin
                email.read!
                body = fetcher.parse_realself_body(email)
              rescue => ex
                p "Error in parsing body: #{ex.message}....Getting raw content."
                body = email.text_part.body.raw_source.to_s.gsub(/[\n \r]+$/, '')
              end

              full_name = body.xpath('//td//b[contains(text(), "Name:")]').first.next.content.downcase
              name = full_name.split(" ")
              email = body.xpath('//td//b[contains(text(), "Email:")]').first.next.content.downcase

              if body.xpath('//td//b[contains(text(), "Phone:")]').first
                phone = body.xpath('//td//b[contains(text(), "Phone:")]').first.next.content.delete("- + () .")
              else
                phone = nil
              end

              if body.xpath('//td//b[contains(text(), "Treatment of interest:")]').first
                procedure = body.xpath('//td//b[contains(text(), "Treatment of interest:")]').first.next.content.parameterize('_')
              else
                procedure = nil
              end

              if body.xpath('//td//b[contains(text(), "Decision Stage:")]').first
                decision_stage = body.xpath('//td//b[contains(text(), "Decision Stage:")]').first.next.content
              else
                decision_stage = nil
              end

              if body.xpath('//td//b[contains(text(), "Comments or questions:")]').first
                comment = body.xpath('//td//b[contains(text(), "Comments or questions:")]').first.next.content
              else
                comment = nil
              end

              # Got the info, Importing now...
              if @current_org.contacts.where(email: email).first
                contact = @current_org.contacts.where(email: email).first
              else
                contact = @current_org.contacts.new
                contact.first_name = name[0]
                contact.last_name = name[1]
                contact.phone = phone
                contact.email = email
                contact.save
              end
              src = @current_org.sources.where(name: /^real self/i, :start_date.lte => Date.today, :end_date.gte => Date.today ).first
              # Created contact.. Now creating lead..
              lead = contact.leads.new
              lead.organization_id = @current_org.id
              lead.first_name = name[0]
              lead.last_name = name[1]
              lead.phone = phone
              lead.email = email
              lead.interested_in = procedure
              lead.stage = 'inquiry'
              lead.source = src
              @current_coordintor = contact.account_rep_id || (lead.user.nil? ? nil : lead.user.id)
              @sales_coordinator_rotation = lead.organization.settings.where(:setting_id => 'coordinator_rotation').first
              @sales_coordinator = @current_coordintor.nil? ? BSON::ObjectId.from_string(@sales_coordinator_rotation.data[0]) : @current_coordintor
              lead.user = @sales_coordinator
              contact.set(account_rep_id: @sales_coordinator)
              @sales_coordinator_rotation.set(:data => @sales_coordinator_rotation.data.rotate())
              lead.created_by = 'CRM'
              lead.save

              if decision_stage
                note = lead.notes.new
                note.body = "Real Self -- Decision Stage:  #{decision_stage}"
                note.save
              end

              if comment
                note = lead.notes.new
                note.body = "Real Self -- Comment:  #{comment}"
                note.save
              end

              # Notifying the lead and the coordinator...
              begin
                send_mail({
                              :subject => "Welcome to #{@current_org.company_name.titleize}",
                              :from_name => "#{lead.user.first_name.titleize} and the #{@current_org.company_name.titleize} Team",
                              :email => lead.email,
                              :name => lead.first_name,
                              :html => render_to_string('/mail_templates/en/new_lead_general', :layout => false, :locals => {:first_name => lead.first_name.titleize, :questionnaire_id => contact.public_token, user_name: lead.user.first_name.titleize}),
                              :from_email => "#{lead.user.email}"
                          })
              rescue
                Rails.logger.info 'Failed to send email to lead.'
              end

              begin
                send_mail({
                              :subject => 'New Lead was created',
                              :from_name => 'Conversion Doctor',
                              :text => 'New lead was created.',
                              :email => lead.user.email,
                              :name => 'Conversion Doctor',
                              :html => render_to_string('/mail_templates/new_lead_created', :layout => false, :locals => {:first_name => lead.first_name.titleize, :lead_id => lead._id, :user => lead.user.first_name.titleize}),
                              :from_email => 'concierge@4beauty.net'
                          })
              rescue
                Rails.logger.info 'Failed to send email to coordinator.'
              end

              # Configuring automatic messages...
              TextWorker.perform_in(1.minute, lead.id)

              TextWorker.perform_in(48.hours, lead.id)
              second_email = render_to_string('/mail_templates/en/new_lead_second_contact', :layout => false, :locals => {:first_name => lead.first_name.titleize, :questionnaire_id => contact.public_token, user_name: lead.user.first_name.titleize})
              EmailWorker.perform_in(48.hours, lead.id, second_email)
              TextWorker.perform_in(216.hours, lead.id)
              third_email = render_to_string('/mail_templates/en/new_lead_third_contact', :layout => false, :locals => {:first_name => lead.first_name.titleize, :questionnaire_id => contact.public_token, user_name: lead.user.first_name.titleize})
              EmailWorker.perform_in(216.hours, lead.id, third_email)

              MigrateWorker.perform_in(264.hours, lead.id)

              impt += 1
              leads[:names].push(lead.first_name)
            else
              p 'Emails are not found in database. Skipping current entry...'
            end
          rescue => ex
            cnt += 1
            p "[#{cnt}] - #{ex.message}. Skipping current entry..."
            raise
          end
        end
        fetcher.logout
      rescue => ex
        p 'Failed to connect to gmail.'
        p ex.message
        flash[:danger] = 'Failed to connect to sales account.'

        redirect_to request.referrer and return
      end
      flash[:success] = "Imported #{impt} leads from OptiCall. \n #{leads[:names]}"
      redirect_to request.referrer
    end


    def import_opticall_emails
      username = ENV['SALES_USERNAME']
      password = ENV['SALES_PASSWORD']

      begin
        fetcher = EmailFetcher.new(username, password)
        unread_emails = fetcher.all_unread_emails
        cnt = 0
        impt = 0
        leads = {names: []}
        consult_date = nil
        procedure_name = nil
        p "Total Unread messages: #{unread_emails.count}"
        unread_emails.each do |email|
          begin
            from = fetcher.from_address(email)
            if from == 'marketing@4beauty.net'
              p "Opening email from #{from}..."
              email.read!

              content = email.text_part.body.raw_source.to_s.gsub(/[\n \r]+$/, '*').split('*')

              phone_index = content.find_index { |x| x.include?('Phone: ') }
              email_index = content.find_index { |x| x.include?('Email: ') }

              p email_index
              p phone_index

              next if phone_index.nil? && email_index.nil?

              email_address = email_index.present? ? content[email_index].split(' ')[1] : content[phone_index].gsub(/\D/, '')
              phone = phone_index.present? ? content[phone_index].gsub(/\D/, '') : nil

              procedure_index = content.find_index { |x| x.include?('Procedure Interest: ') }
              if procedure_index
                procedure_name = content[procedure_index].gsub('Procedure Interest:', '').parameterize('_')
                if @current_org.procedures.where(slug_value: procedure_name).count == 0
                  procedure_name = 'other'
                end
                p procedure_name
              end

              body = fetcher.parse_realself_body(email)
              full_name = body.xpath('//blockquote//p//br').first.previous.content
              name = full_name.split(' ')

              if content.find_index { |x| x.include?('Date/Time: ') }
                consult_date_index = content.find_index { |x| x.include?('Date/Time: ') }
                date = content[consult_date_index].split(' ')[1].gsub('-', '/')
                consult_date = Date.strptime(date, '%m/%d/%Y')
              end

              # Got the info, Importing now...
              if @current_org.contacts.where(email: email_address).first
                contact = @current_org.contacts.where(email: email_address).first
              else
                contact = @current_org.contacts.new
                contact.first_name = name[0]
                contact.last_name = name[1]
                contact.phone = phone
                contact.email = email_address
                contact.save
              end
              src = @current_org.sources.where(name: /^buttsbymendieta/i ).first
              # Created contact.. Now creating lead..
              lead = contact.leads.new
              lead.organization_id = @current_org.id
              lead.first_name = name[0]
              lead.last_name = name[1]
              lead.phone = phone
              lead.email = email_address
              lead.source = src
              lead.interested_in = procedure_name
              if consult_date
                lead.consultation_date = consult_date
              end
              lead.stage = 'inquiry'
              # now current way to determine source
              # lead.source = current_org.sources.where(name: "Real Self").first
              @current_coordintor = contact.account_rep_id || (lead.user.nil? ? nil : lead.user.id)
              @sales_coordinator_rotation = lead.organization.settings.where(:setting_id => 'coordinator_rotation').first
              @sales_coordinator = @current_coordintor.nil? ? BSON::ObjectId.from_string(@sales_coordinator_rotation.data[0]) : @current_coordintor
              lead.user = @sales_coordinator
              contact.set(account_rep_id: @sales_coordinator)
              @sales_coordinator_rotation.set(:data => @sales_coordinator_rotation.data.rotate())
              lead.created_by = 'CRM'
              lead.opticall = true
              lead.save

              if (note_index = content.find_index { |x| x.include?('Notes:') })
                note = lead.notes.new
                note.body = content[note_index..-11].join(" ")
                note.save
              end

              # Notifying the lead and the coordinator...
              begin
                send_mail({
                              :subject => 'Welcome to 4Beauty',
                              :from_name => "#{lead.user.first_name.titleize} and the #{@current_org.company_name.titleize} Team",
                              :text => 'Thank you for contacting the offices of Dr. Mendieta',
                              :email => lead.email,
                              :name => lead.first_name,
                              :html => render_to_string('/mail_templates/en/new_lead_general', :layout => false, :locals => {:first_name => lead.first_name.titleize, :questionnaire_id => contact.public_token, user_name: lead.user.first_name.titleize}),
                              :from_email => "#{lead.user.email}"
                          })
              rescue
                Rails.logger.info 'Failed to send email to lead.'
              end

              begin
                send_mail({
                              :subject => 'New Lead was created',
                              :from_name => '4Beauty CRM',
                              :text => 'New lead was created.',
                              :email => lead.user.email,
                              :name => '#{@current_org.company_name.titleize} Team',
                              :html => render_to_string('/mail_templates/new_lead_created', :layout => false, :locals => {:first_name => lead.first_name.titleize, :lead_id => lead._id, :user => lead.user.first_name.titleize}),
                              :from_email => 'concierge@4beauty.net'
                          })
              rescue
                Rails.logger.info 'Failed to send email to coordinator.'
              end

              # Configuring automatic messages...
              TextWorker.perform_in(1.minute, lead.id)

              TextWorker.perform_in(48.hours, lead.id)
              second_email = render_to_string('/mail_templates/en/new_lead_second_contact', :layout => false, :locals => {:first_name => lead.first_name.titleize, :questionnaire_id => contact.public_token, user_name: lead.user.first_name.titleize})
              EmailWorker.perform_in(48.hours, lead.id, second_email)
              TextWorker.perform_in(216.hours, lead.id)
              third_email = render_to_string('/mail_templates/en/new_lead_third_contact', :layout => false, :locals => {:first_name => lead.first_name.titleize, :questionnaire_id => contact.public_token, user_name: lead.user.first_name.titleize})
              EmailWorker.perform_in(216.hours, lead.id, third_email)

              MigrateWorker.perform_in(264.hours, lead.id)

              impt += 1
              leads[:names].push(lead.first_name)
            else
              p 'Emails are not found in database. Skipping current entry...'
            end
          rescue => ex
            cnt += 1
            p "[#{cnt}] - #{ex.message}. Skipping current entry..."
          end
        end
        fetcher.logout
      rescue => ex
        flash[:danger] = 'Failed to connect to sales account.'
        redirect_to request.referrer and return
      end
      flash[:success] = "Imported #{impt} leads from OptiCall. \n #{leads[:names]}"
      redirect_to request.referrer
    end

  end
end
