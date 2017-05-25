class HealthCheckReportWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(org_id, user_id)
    begin
      @current_org = Business::Organization.find(org_id)
      @user = @current_org.users.find(user_id)

      activity_data(Date.today.beginning_of_month , Date.today.end_of_month)
      first_activity_data(Date.today.beginning_of_month - 1.month, Date.today.end_of_month - 1.month)
      second_activity_data(Date.today.beginning_of_month - 1.year, Date.today.end_of_month - 1.year)

      report = ApplicationController.new.render_to_string('/marketing/reports/health_check_for_worker.html.erb', :layout => 'report',
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
                                :@source_counts => @source_counts,
                                :@first_leads => @first_leads,
                                :@first_leads_count => @first_leads_count,
                                :@first_phone_leads => @first_phone_leads,
                                :@first_phone_leads_count => @first_phone_leads_count,
                                :@first_web_leads => @first_web_leads,
                                :@first_web_leads_count => @first_web_leads_count,
                                :@first_surgeries => @first_surgeries,
                                :@first_surgery_count => @first_surgery_count,
                                :@first_appointments => @first_appointments,
                                :@first_appt_count => @first_appt_count,
                                :@first_completed_surgeries => @first_completed_surgeries,
                                :@first_completed_surgery_count => @first_completed_surgery_count,
                                :@first_cancelled_surgeries => @first_cancelled_surgeries,
                                :@first_cancelled_surgery_count => @first_cancelled_surgery_count,
                                :@first_consults => @first_consults,
                                :@first_consult_count => @first_consult_count,
                                :@first_phone_consults => @first_phone_consults,
                                :@first_web_consults => @first_web_consults,
                                :@first_no_show_consult => @first_no_show_consult,
                                :@first_no_show_consult_count => @first_no_show_consult_count,
                                :@first_cancelled_consult => @first_cancelled_consult,
                                :@first_cancelled_consult_count => @first_cancelled_consult_count,
                                :@first_earned_revenue => @first_earned_revenue,
                                :@first_lost_revenue => @first_lost_revenue,
                                :@first_ita_users => @first_ita_users,
                                :@first_revenue_users => @first_revenue_users,
                                :@first_cr_users => @first_cr_users,
                                :@first_message_users => @first_message_users,
                                :@first_sources => @first_sources,
                                :@first_source_counts => @first_source_counts,
                                :@second_leads => @second_leads,
                                :@second_leads_count => @second_leads_count,
                                :@second_phone_leads => @second_phone_leads,
                                :@second_phone_leads_count => @second_phone_leads_count,
                                :@second_web_leads => @second_web_leads,
                                :@second_web_leads_count => @second_web_leads_count,
                                :@second_surgeries => @second_surgeries,
                                :@second_surgery_count => @second_surgery_count,
                                :@second_appointments => @second_appointments,
                                :@second_appt_count => @second_appt_count,
                                :@second_completed_surgeries => @second_completed_surgeries,
                                :@second_completed_surgery_count => @second_completed_surgery_count,
                                :@second_cancelled_surgeries => @second_cancelled_surgeries,
                                :@second_cancelled_surgery_count => @second_cancelled_surgery_count,
                                :@second_consults => @second_consults,
                                :@second_consult_count => @second_consult_count,
                                :@second_phone_consults => @second_phone_consults,
                                :@second_web_consults => @second_web_consults,
                                :@second_no_show_consult => @second_no_show_consult,
                                :@second_no_show_consult_count => @second_no_show_consult_count,
                                :@second_cancelled_consult => @second_cancelled_consult,
                                :@second_cancelled_consult_count => @second_cancelled_consult_count,
                                :@second_earned_revenue => @second_earned_revenue,
                                :@second_lost_revenue => @second_lost_revenue,
                                :@second_ita_users => @second_ita_users,
                                :@second_revenue_users => @second_revenue_users,
                                :@second_cr_users => @second_cr_users,
                                :@second_message_users => @second_message_users,
                                :@second_sources => @second_sources,
                                :@second_source_counts => @second_source_counts
                              })

          Business::HealthCheckReport.create!(
                                                organization_id: @current_org.id,
                                                body: report.to_s
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

  def first_activity_data(start_date, end_date)

    @first_leads = @current_org.leads.where(:created_at.lte => end_date, :created_at.gte => start_date.beginning_of_day)
    @first_leads_count = @first_leads.count
    @first_phone_leads = @first_leads.where(:created_by.nin => %w(CRM IMPORT))
    @first_phone_leads_count = @first_phone_leads.count
    @first_web_leads = @first_leads.any_of({:created_by => 'CRM'}, {:created_by => 'IMPORT'})
    @first_web_leads_count = @first_web_leads.count
    @first_surgeries = @current_org.surgeries.where(:date.lte => end_date, :date.gte => start_date.beginning_of_day)
    @first_surgery_count = @first_surgeries.count
    @first_appointments = @current_org.consultations.where(:date.lte => end_date, :date.gte => start_date.beginning_of_day)
    @first_appt_count = @first_appointments.count
    @first_completed_surgeries = @first_surgeries.where(:date.lte => end_date, :date.gte => start_date.beginning_of_day).where(completed: true).where(cancelled: false)
    @first_completed_surgery_count = @first_completed_surgeries.count
    @first_cancelled_surgeries = @first_surgeries.where(:date.lte => end_date, :date.gte => start_date.beginning_of_day).where(cancelled: true)
    @first_cancelled_surgery_count = @first_cancelled_surgeries.count
    @first_consults = @first_appointments.where(:cancelled.nin => [true], :no_show.nin  => [true])
    @first_consult_count = @first_consults.count
    @first_phone_consults = @first_phone_leads.select{|lead| lead.consultation.present?}.count
    @first_web_consults = @first_web_leads.select{|lead| lead.consultation.present?}.count
    @first_no_show_consult = @first_appointments.where(no_show: true)
    @first_no_show_consult_count = @first_no_show_consult.count
    @first_cancelled_consult = @first_appointments.where(cancelled: true)
    @first_cancelled_consult_count = @first_cancelled_consult.count
    @first_earned_revenue = @first_completed_surgeries.sum(:cost) || 0
    @first_lost_revenue = @first_cancelled_surgeries.sum(:cost) || 0

    receptionist = @current_org.roles.where({name: 'Receptionist'}).first
    receptionist_users = receptionist.present? ? @current_org.users.where({roles: receptionist.id.to_s}) : []

    sales = @current_org.roles.where({name: 'Sales Coordinator'}).first
    sales_users = sales.present? ? @current_org.users.where({roles: sales.id.to_s}) : []

    @first_ita_users = {}
    receptionist_users.each do |user|
      inq = @first_leads.where({created_by: user.id.to_s}).count
      aps = @first_appointments.collect(&:lead).reject { |e| e.to_s.empty? }.select{ |lead| lead.created_by == user.id.to_s}.count
      @first_ita_users[user.first_name.downcase.to_sym] = (inq == 0) ? 0 : ('%.2f' % (aps.fdiv(inq) * 100)).to_f.round(2)
    end

    @first_revenue_users = {}
    @first_cr_users = {}
      sales_users.each do |user|
        sx = @first_surgeries.where(user: user)
        @first_revenue_users[user.first_name.downcase.to_sym] = sx.completed_surgeries.sum(&:cost)
        surgeries = sx.count
        consults = @first_consults.where(user: user).count
        @first_cr_users[user.first_name.downcase.to_sym] = {consults: 0, surgeries: 0, rate: 0}
        @first_cr_users[user.first_name.downcase.to_sym][:consults] = consults
        @first_cr_users[user.first_name.downcase.to_sym][:surgeries] = surgeries
        @first_cr_users[user.first_name.downcase.to_sym][:rate] = (consults == 0) ? 0 : ('%.2f' % (surgeries.fdiv(consults) * 100)).to_f
      end


      @first_message_users = {}
        sales_users.each do |user|
          messages = injector(@first_leads.where(user: user).collect(&:message_count))
          leads = @first_leads.where(user: user).count
          @first_message_users[user.first_name.downcase.to_sym] = {leads: 0, messages: 0}
          @first_message_users[user.first_name.downcase.to_sym][:leads] = leads
          @first_message_users[user.first_name.downcase.to_sym][:messages] = messages
        end

      @first_sources = @first_leads.collect(&:source).compact.group_by {|src| src.source_type.name}
      @first_source_count = {"source_type" => {"source_id" => " count"}}
      @first_source_counts = {}
      @first_sources.each do |src_typ|
        srcs = src_typ[1].group_by { |src| src.id.to_s}
        srcs.map { |k,v| srcs[k] = srcs[k].count}
        @first_source_counts[src_typ[0]] = srcs
      end
      @first_sources.each {|k,v| @first_sources[k] = {"count" => @first_sources[k].count, "sources" => @first_sources[k].uniq{|x| x.id}}}

  end

  def second_activity_data(start_date, end_date)

    @second_leads = @current_org.leads.where(:created_at.lte => end_date, :created_at.gte => start_date.beginning_of_day)
    @second_leads_count = @second_leads.count
    @second_phone_leads = @second_leads.where(:created_by.nin => %w(CRM IMPORT))
    @second_phone_leads_count = @second_phone_leads.count
    @second_web_leads = @second_leads.any_of({:created_by => 'CRM'}, {:created_by => 'IMPORT'})
    @second_web_leads_count = @second_web_leads.count
    @second_surgeries = @current_org.surgeries.where(:date.lte => end_date, :date.gte => start_date.beginning_of_day)
    @second_surgery_count = @second_surgeries.count
    @second_appointments = @current_org.consultations.where(:date.lte => end_date, :date.gte => start_date.beginning_of_day)
    @second_appt_count = @second_appointments.count
    @second_completed_surgeries = @second_surgeries.where(:date.lte => end_date, :date.gte => start_date.beginning_of_day).where(completed: true).where(cancelled: false)
    @second_completed_surgery_count = @second_completed_surgeries.count
    @second_cancelled_surgeries = @second_surgeries.where(:date.lte => end_date, :date.gte => start_date.beginning_of_day).where(cancelled: true)
    @second_cancelled_surgery_count = @second_cancelled_surgeries.count
    @second_consults = @second_appointments.where(:cancelled.nin => [true], :no_show.nin  => [true])
    @second_consult_count = @second_consults.count
    @second_phone_consults = @second_phone_leads.select{|lead| lead.consultation.present?}.count
    @second_web_consults = @second_web_leads.select{|lead| lead.consultation.present?}.count
    @second_no_show_consult = @second_appointments.where(no_show: true)
    @second_no_show_consult_count = @second_no_show_consult.count
    @second_cancelled_consult = @second_appointments.where(cancelled: true)
    @second_cancelled_consult_count = @second_cancelled_consult.count
    @second_earned_revenue = @second_completed_surgeries.sum(:cost) || 0
    @second_lost_revenue = @second_cancelled_surgeries.sum(:cost) || 0

    receptionist = @current_org.roles.where({name: 'Receptionist'}).first
    receptionist_users = receptionist.present? ? @current_org.users.where({roles: receptionist.id.to_s}) : []

    sales = @current_org.roles.where({name: 'Sales Coordinator'}).first
    sales_users = sales.present? ? @current_org.users.where({roles: sales.id.to_s}) : []

    @second_ita_users = {}
    receptionist_users.each do |user|
      inq = @second_leads.where({created_by: user.id.to_s}).count
      aps = @second_appointments.collect(&:lead).reject { |e| e.to_s.empty? }.select{ |lead| lead.created_by == user.id.to_s}.count
      @second_ita_users[user.first_name.downcase.to_sym] = (inq == 0) ? 0 : ('%.2f' % (aps.fdiv(inq) * 100)).to_f
    end

    @second_revenue_users = {}
    @second_cr_users = {}
      sales_users.each do |user|
        sx = @second_surgeries.where(user: user)
        @second_revenue_users[user.first_name.downcase.to_sym] = sx.completed_surgeries.sum(&:cost)
        surgeries = sx.count
        consults = @second_consults.where(user: user).count
        @second_cr_users[user.first_name.downcase.to_sym] = {consults: 0, surgeries: 0, rate: 0}
        @second_cr_users[user.first_name.downcase.to_sym][:consults] = consults
        @second_cr_users[user.first_name.downcase.to_sym][:surgeries] = surgeries
        @second_cr_users[user.first_name.downcase.to_sym][:rate] = (consults == 0) ? 0 : ('%.2f' % (surgeries.fdiv(consults) * 100)).to_f
      end

      @second_message_users = {}
        sales_users.each do |user|
          messages = injector(@second_leads.where(user: user).collect(&:message_count))
          leads = @second_leads.where(user: user).count
          @second_message_users[user.first_name.downcase.to_sym] = {leads: 0, messages: 0}
          @second_message_users[user.first_name.downcase.to_sym][:leads] = leads
          @second_message_users[user.first_name.downcase.to_sym][:messages] = messages
        end

      @second_sources = @second_leads.collect(&:source).compact.group_by {|src| src.source_type.name}
      @second_source_count = {"source_type" => {"source_id" => " count"}}
      @second_source_counts = {}
      @second_sources.each do |src_typ|
        srcs = src_typ[1].group_by { |src| src.id.to_s}
        srcs.map { |k,v| srcs[k] = srcs[k].count}
        @second_source_counts[src_typ[0]] = srcs
      end
      @second_sources.each {|k,v| @second_sources[k] = {"count" => @second_sources[k].count, "sources" => @second_sources[k].uniq{|x| x.id}}}

  end

  def injector(array)
    if array.length == 0
      0
    else
      array.inject('+')
    end
  end


end
