class AnalyticsReportWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(org_id, user_id, date_hash, type)
    begin
      @current_org = Business::Organization.find(org_id)
      @user = @current_org.users.find(user_id)

      start_date = Date.strptime(date_hash["start"], '%m/%d/%Y').beginning_of_day
      end_date = Date.strptime(date_hash["end"], '%m/%d/%Y').end_of_day

      if type == "on"
        report_type = "activity"
        path = '/marketing/reports/activity_analytics.html.erb'
        activity_data(start_date, end_date)
      else
        report_type = "funnel"
        path = '/marketing/reports/funnel_analytics.html.erb'
        funnel_data(start_date, end_date)
      end

      report = ApplicationController.new.render_to_string(path, :layout => 'report',
                  :locals => {
                                :@current_org => @current_org,
                                :@leads => @leads,
                                :@leads_count => @leads_count,
                                :@phone_leads => @phone_leads,
                                :@phone_leads_count => @phone_leads_count,
                                :@web_leads => @web_leads,
                                :@web_leads_count => @web_leads_count,
                                :@surgeries => @surgeries,
                                :@surgery_count => @surgery_count,
                                :@appointments => @appointments,
                                :@appt_count => @appt_count,
                                :@completed_surgeries => @completed_surgeries,
                                :@completed_surgery_count => @completed_surgery_count,
                                :@cancelled_surgeries => @cancelled_surgeries,
                                :@cancelled_surgery_count => @cancelled_surgery_count,
                                :@consults => @consults,
                                :@consult_count => @consult_count,
                                :@phone_consults => @phone_consults,
                                :@web_consults => @web_consults,
                                :@web_surgeries => @web_surgeries,
                                :@phone_surgeries => @phone_surgeries,
                                :@no_show_consult => @no_show_consult,
                                :@no_show_consult_count => @no_show_consult_count,
                                :@cancelled_consult => @cancelled_consult,
                                :@cancelled_consult_count => @cancelled_consult_count,
                                :@earned_revenue => @earned_revenue,
                                :@lost_revenue => @lost_revenue,
                                :@ita_users => @ita_users,
                                :@revenue_users => @revenue_users,
                                :@cr_users => @cr_users,
                                :@message_users => @message_users,
                                :@sources => @sources,
                                :@source_counts => @source_counts
                              })

          Business::AnalyticsReport.create!(
                                                organization_id: @current_org.id,
                                                body: report.to_s,
                                                type: report_type
                                              )

          Pusher.trigger("private-#{@user.push_channel_id}", 'completed_report', {from: @user.full_name,:subject => 'Your report has successfully completed.'})
        rescue Exception => ex
          Pusher.trigger("private-#{@user.push_channel_id}", 'failed_report', {from: @user.full_name,:subject => 'Your report failed to build. If the error continues please contact your administrator.'})
        end
  end


  def activity_data(start_date, end_date)

    @leads = @current_org.leads.where(:created_at.lte => end_date, :created_at.gte => start_date.beginning_of_day)
    @leads_count = @leads.count
    @phone_leads = @leads.where(:created_by.nin => %w(CRM IMPORT))
    @phone_leads_count = @phone_leads.count
    @web_leads = @leads.any_of({:created_by => 'CRM'}, {:created_by => 'IMPORT'})
    @web_leads_count = @web_leads.count
    @surgeries = @current_org.surgeries.where(:date.lte => end_date, :date.gte => start_date.beginning_of_day)
    @surgery_count = @surgeries.count
    @appointments = @current_org.consultations.where(:date.lte => end_date, :date.gte => start_date.beginning_of_day)
    @appt_count = @appointments.count
    @completed_surgeries = @surgeries.where(:date.lte => end_date, :date.gte => start_date.beginning_of_day, completed: true, cancelled: false)
    @completed_surgery_count = @completed_surgeries.count
    @cancelled_surgeries = @surgeries.where(:date.lte => end_date, :date.gte => start_date.beginning_of_day, cancelled: true)
    @cancelled_surgery_count = @cancelled_surgeries.count
    @consults = @appointments.where(:cancelled.nin => [true], :no_show.nin  => [true])
    @consult_count = @consults.count
    @phone_surgeries = @phone_leads.select{|lead| lead.surgery.present?}.count
    @web_surgeries = @web_leads.select{|lead| lead.surgery.present?}.count
    @phone_consults = @phone_leads.select{|lead| lead.consultation.present?}.count
    @web_consults = @web_leads.select{|lead| lead.consultation.present?}.count
    @no_show_consult = @appointments.where(no_show: true)
    @no_show_consult_count = @no_show_consult.count
    @cancelled_consult = @appointments.where(cancelled: true)
    @cancelled_consult_count = @cancelled_consult.count
    @earned_revenue = @completed_surgeries.sum(:cost) || 0
    @lost_revenue = @cancelled_surgeries.sum(:cost) || 0

    receptionist = @current_org.roles.where({name: 'Receptionist'}).first
    receptionist_users = receptionist.present? ? @current_org.users.where({roles: receptionist.id.to_s}) : []

    sales = @current_org.roles.where({name: 'Sales Coordinator'}).first
    sales_users = sales.present? ? @current_org.users.where({roles: sales.id.to_s}) : []

    @ita_users = {}
    receptionist_users.each do |user|
      inq = @leads.where({created_by: user.id.to_s}).count
      aps = @appointments.collect(&:lead).reject { |e| e.to_s.empty? }.select{ |lead| lead.created_by == user.id.to_s}.count
      @ita_users[user.first_name.downcase.to_sym] = (inq == 0) ? 0 : ('%.2f' % (aps.fdiv(inq) * 100)).to_f
    end

    @revenue_users = {}
    @cr_users = {}
      sales_users.each do |user|
        sx = @surgeries.where(user: user)
        @revenue_users[user.first_name.downcase.to_sym] = sx.completed_surgeries.sum(&:cost)
        surgeries = sx.count
        consults = @consults.where(user: user).count
        @cr_users[user.first_name.downcase.to_sym] = {consults: 0, surgeries: 0, rate: 0}
        @cr_users[user.first_name.downcase.to_sym][:consults] = consults
        @cr_users[user.first_name.downcase.to_sym][:surgeries] = surgeries
        @cr_users[user.first_name.downcase.to_sym][:rate] = (consults == 0) ? 0 : ('%.2f' % (surgeries.fdiv(consults) * 100)).to_f
      end

      @message_users = {}
        sales_users.each do |user|
          messages = injector(@leads.where(user: user).collect(&:message_count))
          leads = @leads.where(user: user).count
          @message_users[user.first_name.downcase.to_sym] = {leads: 0, messages: 0}
          @message_users[user.first_name.downcase.to_sym][:leads] = leads
          @message_users[user.first_name.downcase.to_sym][:messages] = messages
        end

      @sources = @leads.collect(&:source).compact.group_by {|src| src.source_type.name}
      @source_counts = {}
      @sources.each do |src_typ|
        srcs = src_typ[1].group_by { |src| src.id.to_s}
        srcs.map { |k,v| srcs[k] = srcs[k].count}
        @source_counts[src_typ[0]] = srcs
      end
      @sources.each {|k,v| @sources[k] = {"count" => @sources[k].count, "sources" => @sources[k].uniq{|x| x.id}}}

  end

  def funnel_data(start_date, end_date)

    @leads = @current_org.leads.all.where(:created_at.lte => end_date, :created_at.gte => start_date)
    @leads_count = @leads.count
    @phone_leads = @leads.where(:created_by.nin => %w(CRM IMPORT))
    @phone_leads_count = @phone_leads.count
    @web_leads = @leads.any_of({:created_by => 'CRM'}, {:created_by => 'IMPORT'})
    @web_leads_count = @web_leads.count
    @surgeries = @leads.select { |lead| lead.surgery.present?}.collect(&:surgery)
    @surgery_count = @surgeries.count
    @appointments = @leads.select { |lead| lead.consultation.present?}.collect(&:consultation)
    @appt_count = @appointments.count
    @completed_surgeries = @surgeries.select { |sx| sx.completed && !sx.cancelled }
    @completed_surgery_count = @completed_surgeries.count
    @cancelled_surgeries = @surgeries.select { |sx| sx.cancelled }
    @cancelled_surgery_count = @cancelled_surgeries.count
    @consults = @appointments.select { |appt| !appt.no_show && !appt.cancelled }
    @consult_count = @consults.count
    @phone_surgeries = @phone_leads.select{|lead| lead.surgery.present?}.count
    @web_surgeries = @web_leads.select{|lead| lead.surgery.present?}.count
    @phone_consults = @phone_leads.select{|lead| lead.consultation.present?}.count
    @web_consults = @web_leads.select{|lead| lead.consultation.present?}.count
    @no_show_consult = @appointments.select { |appt| appt.no_show }
    @no_show_consult_count = @no_show_consult.count
    @cancelled_consult = @appointments.select { |appt| appt.cancelled }
    @cancelled_consult_count = @cancelled_consult.count
    @earned_revenue = @completed_surgeries.collect(&:cost).inject('+') || 0
    @lost_revenue = @cancelled_surgeries.collect(&:cost).inject('+') || 0

    receptionist = @current_org.roles.where({name: 'Receptionist'}).first
    receptionist_users = receptionist.present? ? @current_org.users.where({roles: receptionist.id.to_s}) : []

    sales = @current_org.roles.where({name: 'Sales Coordinator'}).first
    sales_users = sales.present? ? @current_org.users.where({roles: sales.id.to_s}) : []

    @ita_users = {}
    receptionist_users.each do |user|
      inq = @leads.where({created_by: user.id.to_s}).count
      aps = @appointments.collect(&:lead).reject { |e| e.to_s.empty? }.select{ |lead| lead.created_by == user.id.to_s}.count
      @ita_users[user.first_name.downcase.to_sym] = (inq == 0) ? 0 : ('%.2f' % (aps.fdiv(inq) * 100)).to_f
    end

    @cr_users = {}
      sales_users.each do |user|
        surgeries = @surgeries.select {|sx| sx.user == user}.count
        consults = @consults.select {|appt| appt.user == user}.count
        @cr_users[user.first_name.downcase.to_sym] = {consults: 0, surgeries: 0, rate: 0}
        @cr_users[user.first_name.downcase.to_sym][:consults] = consults
        @cr_users[user.first_name.downcase.to_sym][:surgeries] = surgeries
        @cr_users[user.first_name.downcase.to_sym][:rate] = (consults == 0) ? 0 : ('%.2f' % (surgeries.fdiv(consults) * 100)).to_f
      end

      @sources = @leads.collect(&:source).compact.group_by {|src| src.source_type.name}
      @source_count = {"source_type" => {"source_id" => " count"}}
      @source_counts = {}
      @sources.each do |src_typ|
        srcs = src_typ[1].group_by { |src| src.id.to_s}
        srcs.map { |k,v| srcs[k] = srcs[k].count}
        @source_counts[src_typ[0]] = srcs
      end
      @sources.each {|k,v| @sources[k] = {"count" => @sources[k].count, "sources" => @sources[k].uniq{|x| x.id}}}

  end


  def injector(array)
    if array.length == 0
      0
    else
      array.inject('+')
    end
  end


end
