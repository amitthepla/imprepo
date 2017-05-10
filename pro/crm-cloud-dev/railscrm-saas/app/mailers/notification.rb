class Notification < ActionMailer::Base
  include SendGrid
  include Icalendar
  helper :mailer
  default :from => 'WakeUpSales <no-reply@wakeupsales.com>'
  
  def send_email(to,cc,bcc,subject,msg,file_name,file,frommail='WakeUpSales <no-reply@wakeupsales.com>',activity_id, name, mailer_id,sender)
    @mailer_id = mailer_id
    @message  = msg
    @origin_id = activity_id
    @name = name
    @email = to
    @sender = sender
    if file.present?
      attachments[file_name] = File.read(file) 
    end
    mail(to: to, cc: cc,bcc: bcc, subject: subject, reply_to: sender)
  end
  
  def send_deal_info(email,name,created_by,title,deal_id)
    @name=name
    @created_user=created_by
    @deal_title=title
    @deal_id = deal_id
    mail(to: email, subject: "WakeUpSales: New deal assigned")
  end
  
  def send_task_info(email,name, created_by, due_date,title,url,type,type_id)
    @name=name
    @created_user=created_by
    @task_due_date=due_date
    @task_title=title
	@task_url=url
    @associated_obj_type=type
    @associated_obj_type_id=type_id
    mail(to: email, subject: "WakeUpSales: New task assigned")
  end
  
  def send_event_info(email, start_date, end_date, title, deal_title, con_email)
#    @name=name
#    @created_user=created_by
#    @task_due_date=due_date
#    @task_title=title
#	@task_url=url
#    @associated_obj_type=type
#    @associated_obj_type_id=type_id
#    mail(to: email, subject: "WakeUpSales: New task assigned")
    
    mail(:to => email, :subject => "WakeUpSales: Invitation for the event") do |format|
       format.ics {
       ical = Icalendar::Calendar.new
       e = Icalendar::Event.new
       e.dtstart = DateTime.strptime(start_date.to_s, '%s')
       e.dtend = DateTime.strptime(end_date.to_s, '%s')
       e.organizer = email
       #e.uid "MeetingRequest"
       e.attendee= ["mailto:"+email.to_s, "mailto:"+con_email.to_s]
       e.summary = title
       #e.description = "Have a long lunch meeting and decide nothing..."
       e.ip_class    = "PRIVATE"
       ical.add_event(e)
       ical.publish
       #ical.to_ical
       render :text => ical.to_ical, :layout => false
      }
    end
  end
  
  def test_mail
     mail(:to => "test@test.com", :subject => "WakeUpSales: Invitation for the event") do |format|
       format.ics {
       ical = Icalendar::Calendar.new
       e = Icalendar::Event.new
       e.dtstart = DateTime.strptime("1406715175", '%s')
       e.dtend   = DateTime.strptime("1406715175", '%s')
       e.organizer = "test@test.com"
       #e.uid "MeetingRequest"
       e.attendee= %w(mailto:test@test.com)
       e.summary = "Meeting to discuss regarding the deal."
       e.description = "Have a long lunch meeting and decide nothing..."
       e.ip_class    = "PRIVATE"
       ical.add_event(e)
       ical.publish
       #ical.to_ical
       render :text => ical.to_ical, :layout => false
      }
    end
  end
  
  def mail_notification_to_support user, geo_code
    @user = user
    @geo_code = geo_code
    provider = user.provider
    if user.provider == "google_oauth2"
      email_sub = "Google Sign Up"
      @sign_up_mode = "Google"
    elsif user.provider == "linkedin"
      email_sub = "LinkedIn Sign Up"
      @sign_up_mode = "LinkedIn"
    else
      email_sub = "Sign Up"
      @sign_up_mode = "Normal"
    end
      
    mail(to: "support@wakeupsales.com",cc: "rpt@andolasoft.com", bcc: "ansuman.taria@andolasoft.co.in,amit.mohanty@andolasoft.co.in", subject: "Wakeupsales Cloud Edition New User "+email_sub)
  end

  def mail_notification_to_betauser(email,link)
    @email = email
    @link = link
    mail(to: email, subject: "WakeUpSales: Verify email")  
  end  
  
   def contact_us_mail(email,name,comment,need_help)
     @email = email
     @name = name
     @comment = comment
     @need_help = need_help
     mail(to: "support@wakeupsales.com", bcc: "ansuman.taria@andolasoft.co.in,amit.mohanty@andolasoft.co.in", subject: "Contact Us: Somebody has contacted for Wakeupsales Cloud")  
	 
    end  
  
  
  def mail_notification_to_siteadmin(admin_email, user_email)
    @admin_email = admin_email
    @user_email = user_email
    #mail(to: admin_email, subject: "WakeUpSales: A Beta User Registered")  
	mail(to: admin_email, cc: "test@test.com", subject: "WakeUpSales: A Beta User Registered")  
	
  end
  
 def mail_to_admin_api(admin_email, source, link,contact_name, contact_email,contact_phone,initial_note,subject)
    @admin_email = admin_email
    @contact_name =  contact_name
    @contact_email = contact_email
    @contact_phone = contact_phone
    @initial_note = initial_note
    #@source = source
    @source = subject
    @link = link
    #mail(to: admin_email,  subject: "WakeUpSales: A hot lead entered through "+ source)  
      mail(to: admin_email,  subject: "WakeUpSales: Hotlead via "+ subject)  
  
  end  
  
  def mail_notification_for_signup_to_betauser(email, link)
    @email = email
    @link = link
    mail(to: email, subject: "WakeUpSales: Complete Signup Process")
  end
  def mail_notification_for_password_to_betauser(email, pwd)
    @email = email
    @pwd = pwd
    mail(to: "amit.mohanty@andolasoft.co.in", subject: "WakeUpSales: Password notification")
  end
  
  def bulk_lead_notification assigned_email, name, deals, from=nil
    @email = assigned_email
    @deals = deals
    @name = name
    subject_txt = (from == "reassign" ? "re-assigned" : "assigned")
    mail(to: assigned_email, subject: "WakeUpSales: #{name}, #{deals.count} Deals #{subject_txt} to you")  
  end
  
  def notification_today_task user, tasks, date
     @user = user
     @tasks = tasks     
     mail(to: user.email, subject: "WakeUpSales: #{user.first_name}, Today's tasks #{date}")
  end
  
  def won_deal_notification(a_email,deals,user_name)
     @deal = deals
     @user = user_name
     mail(to:a_email, subject: "WakeUpSales: Cheers a deal has been won")  

    end 
    
    
  def weekly_digest_notification assigned_email, name, deals, timezone, assigned_to, total_deal, dealassigned,frequency
    @email = assigned_email
    @deals = deals
    @name = name
    @day = timezone.strftime("%A").to_s
    @assigned_to = assigned_to
    @total_deal = total_deal 
    @dealassigned = dealassigned
	
    crypt = ActiveSupport::MessageEncryptor.new(Rails.configuration.secret_token)
    encrypted_user_id = crypt.encrypt_and_sign(assigned_to)
	@url = (Rails.env == "production" ? "https://wakeupsales.com" : "http://staging.wakeupsales.com") + "/update_weekly_digest?user_id=#{encrypted_user_id}"
    
    #We have listed all of these active deals in the pipeline, which you might need to work on: 
    if total_deal > 10
      @header_txt = "You have #{total_deal} deals assigned to you need attention!"
      @body_txt = "#{@dealassigned} out of #{@total_deal}"
    else
      @header_txt = ""
      @body_txt = "all of these"
    end

    mail(to: assigned_email, subject: "WakeUpSales: #{frequency} Digest Email - #{timezone.strftime('%m').to_s}/#{timezone.strftime('%d').to_s}")
    #mail(to: "ansuman.taria@andolasoft.co.in", subject: "WakeUpSales: Weekly Digest Email - #{timezone.strftime('%m').to_s}/#{timezone.strftime('%d').to_s}")
  end
  
  def assign_priority_deal_notification(a_email,deals,user_name,assigned_to)
     @deal = deals
     @user = user_name
	   crypt = ActiveSupport::MessageEncryptor.new(Rails.configuration.secret_token)
	   @encrypted_lead_token = crypt.encrypt_and_sign(@deal.hot_lead_token)
	   @assigned_to = crypt.encrypt_and_sign(assigned_to)
     mail(to:a_email,subject: "WakeUpSales: \'#{@deal.title}\' has been assigned to you")  
     #mail(to: "amit.mohanty@andolasoft.co.in", subject: "WakeUpSales: \'#{@deal.title}\' has been primarily assigned to you")  
   end   
    
  def latest_blog_notification email,contact_id, guid, title, content
    #@email = assigned_email
	puts "latest blog notification========>"
	@guid = guid
    @title = title
	@content = content
    crypt = ActiveSupport::MessageEncryptor.new(Rails.configuration.secret_token)
    @encrypted_lead_token = crypt.encrypt_and_sign(contact_id)
    @contact_id = crypt.encrypt_and_sign(contact_id)
    mail(to: email, subject: "WakeUpSales Blog: \'#{@title}\'")
  end

  def send_email_to_downloader(name,to)
    @name = name
    mail(to: to, subject: "Free Download WakeUpSales Community Edition")
  end

  def send_email_to_admin(name,email,location)
    @name = name
    @email = email
    @location = location
    mail(to: "support@wakeupsales.org", bcc: "ansuman.taria@andolasoft.co.in,amit.mohanty@andolasoft.co.in", subject: "Free Download WakeUpSales Community Edition")
  end
  def send_beta_request_to_admin(email)
    @email = email
    mail(to: "ansuman.taria@andolasoft.co.in", subject: "New beta request")
  end
  def send_beta_request_to_user(email)
    @email = email
    mail(to: "ansuman.taria@andolasoft.co.in", subject: "New beta request")
  end


  def send_invoice_email(email, cc, org, invoice, invoice_item,sub,pd_invoice)
    @email = email
    @org = org
    @invoice = invoice
    @invoice_items = invoice_item
    if sub == ""
      sub = "Invoice from #{@org} Inc."
    end
    attachments.inline["#{@invoice.company_name.gsub(' ','_')}_#{@invoice.invoice_no}.pdf"] = pd_invoice.render_pdf#, :filename => "Invoice #{@invoice.invoice_no}.pdf", :type => "application/pdf", :disposition => "inline"
    mail(to: @email,cc: cc, subject: sub)
  end
  def send_invoice_paid_email(email, org, invoice, invoice_item,pd_invoice)
    @email = email
    @org = org
    @invoice = invoice
    @invoice_items = invoice_item
    attachments.inline["#{@invoice.company_name.gsub(' ','_')}_#{@invoice.invoice_no}.pdf"] = pd_invoice.render_pdf
    mail(to: @email, subject: "We have received your payment towards #{@org}")
  end

  def send_invoice_cancel_email(email, org, invoice, invoice_item)
    @email = email
    @org = org
    @invoice = invoice
    @invoice_items = invoice_item
    mail(to: @email, subject: "Your Invoice has been cancelled towards #{@org}")
  end
  # Send email to assigned user after a task has been created.
  def send_assigned_email_notification( user, task, created_by)
    @user = user
    @created_by = created_by
    @task = task
    mail(to: user.email, subject: "WakeUpSales - You Have A New Task (#{task.title})")
  end
  def send_feedback_to_user(name,email)
    @name = name
    @email = email
    mail(to: email, subject: "WakeUpSales: Thank you for your Feedback")

  end
  def send_feedback_to_support(name,email,company,desc)
    @name = name
    @email = email
    @company = company
    @desc = desc
    mail(to: "support@wakeupsales.com", bcc: "ansuman.taria@andolasoft.co.in,amit.mohanty@andolasoft.co.in", subject: "WakeUpSales: Feedback from user (In app)")

  end
  def send_daily_updates(user_ids, deal)
    @deal = deal
    
    @emails = User.where("id IN (?)",user_ids.split(",")).map(&:email)
    mail(to: @emails, subject: "WakeUpSales: Daily Updates Reminder")
  end

  def plugin_payment_success(plugin_trans, invoice_id, token, pd_invoice)
    @plugin_trans = plugin_trans
    @invoice_id = invoice_id
    @token = token
    @url = (Rails.env == "production" ? "https://wakeupsales.com" : "http://stage-saas.wakeupsales.com") + "/plugin/#{token}/download"
    case @plugin_trans.community_plugin.name.downcase
    when 'sendgrid'
      @integration_url = "http://wakeupsales.org/sendgrid-integration.php#tab-3"    
    else
      @integration_url = nil
    end
    
    attachments.inline["WakeUpSales_#{@plugin_trans.community_plugin.name}_Invoice_#{@invoice_id}.pdf"] = pd_invoice.render_pdf
    #mail(to:@plugin_trans.email, subject: "Successfully purchased '#{@plugin_trans.community_plugin.name}' Plugin for WakeUpSales Community Edition")
    mail(to:@plugin_trans.email, bcc: "support@wakeupsales.org,omkar.rath@andolasoft.co.in,amit.mohanty@andolasoft.co.in,ansuman.taria@andolasoft.co.in", subject: "Successfully purchased '#{@plugin_trans.community_plugin.name}' Plugin for WakeUpSales Community Edition")
    #Successfully purchased Time Log Add-on for Orangescrum Community Edition
  end

  def plugin_payment_error(user_name,user_email,plugin, message)
    @user_name = user_name
    @user_email = user_email
    @message = message
    @plugin = plugin
    #mail(to:"ansuman.taria@andolasoft.co.in", subject: "Alert - Wrong card details entered during #{@plugin.is_plugin ? 'an Plugin' : 'installation support'} Purchase")
    mail(to:"support@wakeupsales.org", bcc: "omkar.rath@andolasoft.co.in,amit.mohanty@andolasoft.co.in,ansuman.taria@andolasoft.co.in", subject: "Alert - Wrong card details entered during #{@plugin.is_plugin ? 'an Plugin' : 'installation support'} Purchase")
    #ALERT MESSAGE FROM ORANGESCRUM ON CREDIT CARD FAILD DURING BUY ADD-ON
  end

  def admin_plugin_payment_notification(user_name, user_email, plugin, geo_code)
    @user_name = user_name
    @user_email = user_email
    @plugin = plugin
    @geo_code = geo_code
    #mail(to:"ansuman.taria@andolasoft.co.in", subject: "'#{user_name}' requests '#{plugin}' Plugin on WakeUpSales Community")
    mail(to:"support@wakeupsales.org",bcc: "rpt@andolasoft.com,omkar.rath@andolasoft.co.in,amit.mohanty@andolasoft.co.in,ansuman.taria@andolasoft.co.in", subject: "'#{user_name}' requests '#{plugin}' Plugin on WakeUpSales Community")
    # 'Chetan Patwardhan' requests Time Log Add-on on Orangescrum Community
  end
  # Send bug report to User
  def send_bug_report_to_user(name, email)
    @name = name
    @email = email 
    mail(to: email, subject: "Thanks for your help | WakeUpSales")
  end
  # Send bug report to Support
  def send_bug_report_to_support(name, email, bug_type, comments)
    @name = name
    @email = email
    @bug_type = bug_type
    @comments = comments
    mail(to: "support@wakeupsales.com", subject: "New Bug Report in WakeUpSales Cloud Edition")
  end
  def installation_support(plugin_trans, invoice_id, token, pd_invoice)
    @plugin_trans = plugin_trans
    @invoice_id = invoice_id
    @token = token
    
    attachments.inline["WakeUpSales_#{@plugin_trans.community_plugin.name}_Invoice_#{@invoice_id}.pdf"] = pd_invoice.render_pdf
    mail(to:@plugin_trans.email, bcc: "rpt@andolasoft.com,support@wakeupsales.org,omkar.rath@andolasoft.co.in,amit.mohanty@andolasoft.co.in,ansuman.taria@andolasoft.co.in", subject: "Congratulations! Successfully purchased On-Premises Installation & Support for your WakeUpSales Community Edition")
    #Successfully purchased Time Log Add-on for Orangescrum Community Edition
  end
  def send_create_form_notification(email_to, cc_email=nil, web_form_name, user_email)
    @web_form_name = web_form_name
    @user_email = user_email
    mail(to: email_to, cc:cc_email.present? ? cc_email : "", subject: "Wakeupsales new lead/contact has been created from your website: #{web_form_name}")
  end
  def send_web_form_thank_you_to_user(full_name, email, org_name)
    @full_name = full_name
    @org_name = org_name
    mail(to: email, subject: "Thanks a ton for getting in touch!")
  end

   def subscription_payment_error(message)
    @message = message
    mail(to:"amit.mohanty@andolasoft.co.in", subject: "Alert - Subscription Error")    
  end

  def subscription_payment_success(message)
    @message = message
    mail(to:"amit.mohanty@andolasoft.co.in", subject: "Alert - Subscription Success")
  end

  def subscription_cancel(message)
    @message = message
    mail(to:"amit.mohanty@andolasoft.co.in", subject: "Alert - Subscription Cancelled")
  end

  def subscription_payment_notification(message,amount)
    @message = message
    @amount = amount
    mail(to:"amit.mohanty@andolasoft.co.in", subject: message)
  end

end
