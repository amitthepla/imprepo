class Marketing::DashboardController < MarketingController
  include ActionView::Helpers::NumberHelper
  layout 'report', only: [:view_health_check]
  def index

    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.strptime(params[:start_date], '%m/%d/%Y').beginning_of_day
      end_date = Date.strptime(params[:end_date], '%m/%d/%Y').end_of_day
    else
      start_date = Date.today.beginning_of_month
      end_date = Date.today.end_of_month
    end

    activity_data(start_date, end_date)

  end

  def get_chart
    @chart = params[:chart]
    @view = params[:view]
    render :file => "app/views/marketing/dashboard/get_chart.js.erb"
  end

  def activity_analytics
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.strptime(params[:start_date], '%m/%d/%Y').beginning_of_day
      end_date = Date.strptime(params[:end_date], '%m/%d/%Y').end_of_day
    else
      start_date = Date.today.beginning_of_month
      end_date = Date.today.end_of_month
    end

    if start_date < Date.new(2016, 5, 1)
      include_historical_data(start_date, end_date, params["analytics_type"].present?)
    else
      dynamic_search(start_date, end_date, params["analytics_type"].present?)
    end

    if params["analytics_type"].present?
      respond_to do |format|
        format.js
      end
    else
      respond_to do |format|
        format.js { render :file => "app/views/marketing/dashboard/funnel.js.erb" }
      end
    end

  end


  def snapshot
    @start_date = Date.strptime(params[:start_date], '%m/%d/%Y')
    @end_date = Date.strptime(params[:end_date], '%m/%d/%Y')

    render :partial => 'snapshot'
  end

  def dashboard
    sales = @current_org.roles.where({name: 'Sales Coordinator'}).first
    @sales_coordinators = sales.present? ? @current_org.users.where({roles: sales.id.to_s}).entries : []
    @last_coordinator = @sales_coordinators.last

  end

  def filtered_data_count
    search_type = "activity"
    start_date = Date.strptime(params[:start_date], '%m/%d/%Y')
    end_date = Date.strptime(params[:end_date], '%m/%d/%Y')
    data_counts = get_filtered_data_counts(start_date, end_date, search_type)
    render json: {data: data_counts}, status: :ok
  end

  def diagnostic_filter
    now_start_date = Date.strptime(params[:now_start_date], '%m/%d/%Y')
    now_end_date = Date.strptime(params[:now_end_date], '%m/%d/%Y')
    then_start_date = Date.strptime(params[:then_start_date], '%m/%d/%Y')
    then_end_date = Date.strptime(params[:then_end_date], '%m/%d/%Y')

    now_data = get_filtered_data_counts(now_start_date, now_end_date, search_type)
    then_data = get_filtered_data_counts(then_start_date, then_end_date, search_type)
    data = {now_data: now_data, then_data: then_data}
    data[:percentage] = get_percentege(now_data, then_data)
    render json: {data: data}, status: :ok
  end

  def diagnostic

    if !params[:first_start_date].present? || !params[:first_end_date].present? || !params[:second_start_date].present? || !params[:second_end_date].present?
      params[:first_start_date] =  (Date.today.beginning_of_month - 1.month ).strftime('%m/%d/%Y')
      params[:first_end_date] = (Date.today.end_of_month - 1.month ).strftime('%m/%d/%Y')
      params[:second_start_date] =  Date.today.beginning_of_month.strftime('%m/%d/%Y')
      params[:second_end_date] = Date.today.end_of_month.strftime('%m/%d/%Y')
    end

    first_start_date = Date.strptime(params[:first_start_date], '%m/%d/%Y')
    first_end_date = Date.strptime(params[:first_end_date], '%m/%d/%Y')
    second_start_date = Date.strptime(params[:second_start_date], '%m/%d/%Y')
    second_end_date = Date.strptime(params[:second_end_date], '%m/%d/%Y')

    first_activity_data(first_start_date, first_end_date)
    second_activity_data(second_start_date, second_end_date)

  end

  private



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
    @consults = @appointments.where(no_show: false, cancelled: false)
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
      aps = @appointments.collect(&:lead).select{ |lead| lead.created_by == user.id.to_s}.count
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
    @first_consults = @first_appointments.where(no_show: false, cancelled: false)
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
      aps = @first_appointments.collect(&:lead).select{ |lead| lead.created_by == user.id.to_s}.count
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
    @second_consults = @second_appointments.where(no_show: false, cancelled: false)
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
      aps = @second_appointments.collect(&:lead).select{ |lead| lead.created_by == user.id.to_s}.count
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
      aps = @appointments.collect(&:lead).select{ |lead| lead.created_by == user.id.to_s}.count
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

  def dynamic_search(start_date, end_date, search_type)
    if search_type
      activity_data(start_date, end_date)
    else
      funnel_data(start_date, end_date)
    end
  end

  def include_historical_data(start_date, end_date, search_type)
    if end_date < Date.new(2016, 5, 1).beginning_of_day
      ending_date = Date.new(2016, 5, 1).beginning_of_day
    else
      ending_date = end_date
    end

    if search_type
      activity_data(Date.new(2016, 5, 1).beginning_of_day, ending_date)
    else
      funnel_data(Date.new(2016, 5, 1).beginning_of_day, ending_date)
    end

    start_range = start_date.month
    end_range = (end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month) + start_range
    static_data = YAML.load_file(Rails.root.join('config', 'filtered_data.yml'))
    iterations = 1
    (start_range..end_range).each_with_index do |month, index|
      iterations = index + 1
      filter = start_date + index.months
      break if filter.year  == 2016 && filter.month > 4
      @phone_leads_count += static_data[filter.year][filter.month]['phone_calls']
      @web_leads_count += static_data[filter.year][filter.month]['emails']
      @leads_count += static_data[filter.year][filter.month]['total_leads']
      @appt_count += static_data[filter.year][filter.month]['appointments']
      @consult_count += static_data[filter.year][filter.month]['consultation']
      @surgery_count += static_data[filter.year][filter.month]['booked_procedures']
      @completed_surgery_count += static_data[filter.year][filter.month]['completed_procedures']
      @cancelled_surgery_count += static_data[filter.year][filter.month]['cancelled_procedures']
      @earned_revenue += static_data[filter.year][filter.month]['earned_revenue']
      @lost_revenue += static_data[filter.year][filter.month]['lost_revenue']
      @no_show_consult_count += (static_data[filter.year][filter.month]['appointments'] * (static_data[filter.year][filter.month]['no_show_rate'] / 100)).to_i
      @cancelled_consult_count += (static_data[filter.year][filter.month]['appointments'] * (static_data[filter.year][filter.month]['cancel_rate'] / 100)).to_i
    end
  end

  def include_historical_data_for_health_check(start_date, end_date)
    second_activity_data(start_date, end_date)
    start_range = start_date.month
    end_range = (end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month) + start_range
    static_data = YAML.load_file(Rails.root.join('config', 'filtered_data.yml'))
    iterations = 1
    (start_range..end_range).each_with_index do |month, index|
      iterations = index + 1
      filter = start_date + index.months
      break if filter.year  == 2016 && filter.month > 4
      @second_phone_leads_count += static_data[filter.year][filter.month]['phone_calls']
      @second_web_leads_count += static_data[filter.year][filter.month]['emails']
      @second_leads_count += static_data[filter.year][filter.month]['total_leads']
      @second_appt_count += static_data[filter.year][filter.month]['appointments']
      @second_consult_count += static_data[filter.year][filter.month]['consultation']
      @second_surgery_count += static_data[filter.year][filter.month]['booked_procedures']
      @second_completed_surgery_count += static_data[filter.year][filter.month]['completed_procedures']
      @second_cancelled_surgery_count += static_data[filter.year][filter.month]['cancelled_procedures']
      @second_earned_revenue += static_data[filter.year][filter.month]['earned_revenue']
      @second_lost_revenue += static_data[filter.year][filter.month]['lost_revenue']
      @second_no_show_consult_count += (static_data[filter.year][filter.month]['appointments'] * (static_data[filter.year][filter.month]['no_show_rate'] / 100)).to_i
      @second_cancelled_consult_count += (static_data[filter.year][filter.month]['appointments'] * (static_data[filter.year][filter.month]['cancel_rate'] / 100)).to_i
    end
  end





  def get_percentege(now_data, then_data)
    percent_data = {}
    now_data.each do |k, v|
      if %w(earned_revenue lost_revenue).include?(k.to_s)
        now = now_data[k].to_s.gsub(/[$,]/, '').to_f
        thn = then_data[k].to_s.gsub(/[$,]/, '').to_f
        percent_data[k] = ('%.2f' % (((now - thn).fdiv(thn)) * 100)).to_f
      elsif v.is_a?(String) || then_data[k].is_a?(String) || then_data[k] == 0
        percent_data[k] = 0
      elsif %w(closing_rate_users).include?(k.to_s)
        individual_data = {}
        v.each do |s_k, s_v|
          next if now_data[k][s_k].nil? || then_data[k][s_k].nil?
          individual_data[s_k] = ('%.2f' % (((now_data[k][s_k][:rate].to_f - then_data[k][s_k][:rate].to_f).fdiv(then_data[k][s_k][:rate].to_f)) * 100)).to_f
        end
        percent_data[k] = individual_data
      elsif v.is_a?(Hash)
        individual_data = {}
        v.each do |s_k, s_v|
          individual_data[s_k] = ('%.2f' % (((now_data[k][s_k].to_f - then_data[k][s_k].to_f).fdiv(then_data[k][s_k].to_f)) * 100)).to_f
        end
        percent_data[k] = individual_data
      else
        percent_data[k] = ('%.2f' % (((now_data[k] - then_data[k]).fdiv(then_data[k])) * 100)).to_f
        # ((now number - then number) / then number)) x 100
      end
    end
    percent_data
  end

  def load_yaml_file
    YAML.load_file(Rails.root.join('config', 'filtered_data.yml'))
  end

  def get_data_from_yaml(start_date, end_date)
    start_range = start_date.month
    end_range = (end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month) + start_range
    static_data = load_yaml_file
    iterations = 1
    data = {
        phone_calls: 0,
        emails: 0,
        total_leads: 0,
        appointments: 0,
        consultations: 0,
        scheduled_surgeries: 0,
        completed: 0,
        cancelled: 0,
        cancelled_consultations: 0,
        cancel_rate: 0,
        phone: 0,
        email: 0,
        no_show_rate: 0,
        earned_revenue: 0,
        lost_revenue: 0,
        closing_rate_total: 0,
        internet: 0,
        referral: 0,
        relations: 0,
        radio: 0,
        print: 0,
        events: 0,
        tv: 0,
        outdoor: 0,
        walkin: 0,
        other: 0,
        closing_rate_users: {
            vivian: {
                consults: 0,
                surgeries: 0,
                rate: 0
            },
            camille: {
                consults: 0,
                surgeries: 0,
                rate: 0
            },
            colleen: {
                consults: 0,
                surgeries: 0,
                rate: 0
            },
            pinina: {
                consults: 0,
                surgeries: 0,
                rate: 0
            },
            marisol: {
                consults: 0,
                surgeries: 0,
                rate: 0
            }
        },
        inquiry_to_appointment_total: 0,
        inquiry_to_appointment_users: {
            alejandra: 0,
            opticall: 0,
            colleen: 0
        }
    }

    (start_range..end_range).each_with_index do |month, index|
      iterations = index + 1
      filter = start_date + index.months
      data[:phone_calls] += static_data[filter.year][filter.month]['phone_calls']
      data[:emails] += static_data[filter.year][filter.month]['emails']
      data[:total_leads] += static_data[filter.year][filter.month]['total_leads']
      data[:appointments] += static_data[filter.year][filter.month]['appointments']
      data[:consultations] += static_data[filter.year][filter.month]['consultation']
      data[:scheduled_surgeries] += static_data[filter.year][filter.month]['booked_procedures']
      data[:completed] += static_data[filter.year][filter.month]['completed_procedures']
      data[:cancelled] += static_data[filter.year][filter.month]['cancelled_procedures']
      data[:earned_revenue] += static_data[filter.year][filter.month]['earned_revenue']
      data[:lost_revenue] += static_data[filter.year][filter.month]['lost_revenue']

      data[:inquiry_to_appointment_total] += static_data[filter.year][filter.month]['inquiry_to_appointment']
      data[:no_show_rate] += static_data[filter.year][filter.month]['no_show_rate']
      data[:cancel_rate] += static_data[filter.year][filter.month]['cancel_rate']

      data[:internet] += static_data[filter.year][filter.month]['internet']
      data[:referral] += static_data[filter.year][filter.month]['referral']
      data[:relations] += static_data[filter.year][filter.month]['relations']
      data[:radio] += static_data[filter.year][filter.month]['radio']
      data[:print] += static_data[filter.year][filter.month]['print']
      data[:events] += static_data[filter.year][filter.month]['events']
      data[:tv] += static_data[filter.year][filter.month]['tv']
      data[:outdoor] += static_data[filter.year][filter.month]['outdoor']
      data[:walkin] += static_data[filter.year][filter.month]['walkin']
      data[:other] += static_data[filter.year][filter.month]['other']

      data[:closing_rate_total] += static_data[filter.year][filter.month]['closing_rate']['total']
      data[:closing_rate_users][:vivian][:rate] += static_data[filter.year][filter.month]['closing_rate']['vivian']
      data[:closing_rate_users][:camille][:rate] += static_data[filter.year][filter.month]['closing_rate']['camille']
      data[:closing_rate_users][:colleen][:rate] += static_data[filter.year][filter.month]['closing_rate']['colleen']
      data[:closing_rate_users][:pinina][:rate] += static_data[filter.year][filter.month]['closing_rate']['pinina']
      data[:closing_rate_users][:marisol][:rate] += static_data[filter.year][filter.month]['closing_rate']['marisol']
    end

    data[:inquiry_to_appointment_total] = data[:total_leads] == 0 ? 0 : ('%.2f' % (data[:appointments].fdiv(data[:total_leads]) * 100)).to_f
    data[:no_show_rate] = ('%.2f' % (data[:no_show_rate] / iterations)).to_f
    data[:cancel_rate] = data[:scheduled_surgeries] == 0 ? 0 : ('%.2f' % (data[:cancelled].fdiv(data[:scheduled_surgeries]) * 100)).to_f
    data[:closing_rate_total] = data[:scheduled_surgeries] == 0 ? 0 : ('%.2f' % (data[:completed].fdiv(data[:scheduled_surgeries]) * 100)).to_f
    data[:closing_rate_users][:vivian][:rate] = ('%.2f' % (data[:closing_rate_users][:vivian][:rate] / iterations)).to_f
    data[:closing_rate_users][:camille][:rate] = ('%.2f' % (data[:closing_rate_users][:camille][:rate] / iterations)).to_f
    data[:closing_rate_users][:colleen][:rate] = ('%.2f' % (data[:closing_rate_users][:colleen][:rate] / iterations)).to_f
    data[:closing_rate_users][:pinina][:rate] = ('%.2f' % (data[:closing_rate_users][:pinina][:rate] / iterations)).to_f
    data[:closing_rate_users][:marisol][:rate] = ('%.2f' % (data[:closing_rate_users][:marisol][:rate] / iterations)).to_f

    data
  end

  def get_data_count(start_date, end_date, search_type)
    begin
      leads = Business::Lead.where(organization: @current_org)
      end_date = end_date + 1.day
      total_leads = leads.where({created_at: {'$lt' => end_date, '$gte' => start_date}})

      if search_type == "activity"
        scheduled_surgeries_count = leads.where({procedure_date: {'$lt' => end_date, '$gte' => start_date}}).count
        appointments = leads.where({consultation_date: {'$lt' => end_date, '$gte' => start_date}})
        consultations = appointments.where({cancelled_consult: false, no_show: false}).count
        cancelled_consultations = appointments.where({cancelled_consult: true, no_show: false}).count
        no_show = appointments.where({no_show: true}).count
        completed_surgeries = leads.where({procedure_date: {'$lt' => end_date, '$gte' => start_date}}).where({surgery_completed: true})
        cancelled_surgeries = leads.where({procedure_date: {'$lt' => end_date, '$gte' => start_date}}).where({cancelled_surgery: true})
        earned_revenue = completed_surgeries.map(&:surgery_cost).map(&:to_i).reduce(&:+)
        lost_revenue = cancelled_surgeries.map(&:surgery_cost).map(&:to_i).reduce(&:+)
      elsif search_type == "funnel"
        scheduled_surgeries_count = total_leads.where({:procedure_date.ne => nil}).count
        appointments = total_leads.where({:consultation_date.ne => nil})
        consultations = appointments.where({cancelled_consult: false, no_show: false}).count
        cancelled_consultations = appointments.where({cancelled_consult: true, no_show: false}).count
        no_show = appointments.where({no_show: true}).count
        completed_surgeries = total_leads.where({surgery_completed: true})
        cancelled_surgeries = total_leads.where({cancelled_surgery: true})
        earned_revenue = completed_surgeries.map(&:surgery_cost).map(&:to_i).reduce(&:+)
        lost_revenue = cancelled_surgeries.map(&:surgery_cost).map(&:to_i).reduce(&:+)
      end

      existing = total_leads.where({:created_by.nin => ['', nil]})
      email = existing.where({:created_by => 'CRM'})
      phone = existing.where({:created_by.nin => ['CRM']})
      email_appointments = email.where({:consultation_date.ne => nil}).count
      phone_appointments = phone.where({:consultation_date.ne => nil}).count

      receptionist = @current_org.roles.where({name: 'Receptionist'}).first
      receptionist_users = receptionist.present? ? @current_org.users.where({roles: receptionist.id.to_s}) : []

      sales = @current_org.roles.where({name: 'Sales Coordinator'}).first
      sales_users = sales.present? ? @current_org.users.where({roles: sales.id.to_s}) : []

      ita_users = {}
      receptionist_users.each do |user|
        inq = total_leads.where({created_by: "#{user.full_name}"}).count
        aps = appointments.where({created_by: "#{user.full_name}"}).count
        ita_users[user.first_name.downcase.to_sym] = (inq == 0) ? 0 : ('%.2f' % (aps.fdiv(inq) * 100)).to_f
      end

      cr_users = {}
      if search_type == "activity"
        sales_users.each do |user|
          scheduled = total_leads.where({:procedure_date.ne => nil, user: user}).count
          consult = total_leads.where({:consultation_date.ne => nil, cancelled_consult: false, no_show: false, user: user}).count
          cr_users[user.first_name.downcase.to_sym] = {consults: 0, surgeries: 0, rate: 0}
          cr_users[user.first_name.downcase.to_sym][:consults] = consult
          cr_users[user.first_name.downcase.to_sym][:surgeries] = scheduled
          cr_users[user.first_name.downcase.to_sym][:rate] = (consult == 0) ? 0 : ('%.2f' % (scheduled.fdiv(consult) * 100)).to_f
        end
      elsif search_type == "funnel"
        sales_users.each do |user|
          scheduled = leads.where({procedure_date: {'$lt' => end_date, '$gte' => start_date}, user: user}).count
          consult = leads.where({consultation_date: {'$lt' => end_date, '$gte' => start_date}, cancelled_consult: false, no_show: false, user: user}).count
          cr_users[user.first_name.downcase.to_sym] = {consults: 0, surgeries: 0, rate: 0}
          cr_users[user.first_name.downcase.to_sym][:consults] = consult
          cr_users[user.first_name.downcase.to_sym][:surgeries] = scheduled
          cr_users[user.first_name.downcase.to_sym][:rate] = (consult == 0) ? 0 : ('%.2f' % (scheduled.fdiv(consult) * 100)).to_f
        end
      end
      {
          phone_calls: phone.count,
          emails: email.count,
          total_leads: total_leads.count,
          appointments: appointments.count,
          consultations: consultations,
          scheduled_surgeries: scheduled_surgeries_count,
          completed: completed_surgeries.count,
          cancelled: cancelled_surgeries.count,
          # cancelled_consultations: cancelled_consultations == 0 ? 0 : ('%.2f' % (consultations.fdiv(cancelled_consultations) * 100)).to_f,
          cancelled_consultations: cancelled_consultations,
          cancel_rate: scheduled_surgeries_count == 0 ? 0 : ('%.2f' % (cancelled_surgeries.count.fdiv(scheduled_surgeries_count) * 100)).to_f,
          phone: email.count == 0 ? 0 : ('%.2f' % (email_appointments.fdiv(email.count) * 100)).to_f,
          email: phone.count == 0 ? 0 : ('%.2f' % (phone_appointments.fdiv(phone.count) * 100)).to_f,
          no_show_rate: consultations == 0 ? 0 : ('%.2f' % (no_show.fdiv(consultations) * 100)).to_f,
          earned_revenue: earned_revenue.present? ? earned_revenue : 0,
          lost_revenue: lost_revenue.present? ? lost_revenue : 0,
          closing_rate_total: consultations == 0 ? 0 : ('%.2f' % (scheduled_surgeries_count.fdiv(consultations) * 100)).to_f,
          internet: (total_leads.in(source: SourceType.by_name('Internet').first.sources.map(&:id)).count rescue 0),
          referral: (total_leads.in(source: SourceType.by_name('Referral').first.sources.map(&:id)).count rescue 0),
          relations: 0,
          radio: (total_leads.in(source: SourceType.by_name('Traditional Media').first.sources.map(&:id)).count rescue 0),
          print: (total_leads.in(source: SourceType.by_name('Traditional Media').first.sources.map(&:id)).count rescue 0),
          events: (total_leads.in(source: SourceType.by_name('Events').first.sources.map(&:id)).count rescue 0),
          tv: (total_leads.in(source: SourceType.by_name('Traditional Media').first.sources.map(&:id)).count rescue 0),
          outdoor: (total_leads.in(source: SourceType.by_name('Social Media').first.sources.map(&:id)).count rescue 0),
          walkin: (total_leads.in(source: SourceType.by_name('Walk-In').first.sources.map(&:id)).count rescue 0),
          other: (total_leads.in(source: SourceType.by_name('Other').first.sources.map(&:id)).count rescue 0),
          closing_rate_users: cr_users,
          inquiry_to_appointment_total: (total_leads.count == 0) ? 0 : ('%.2f' % (appointments.count.fdiv(total_leads.count) * 100)).to_f,
          inquiry_to_appointment_users: ita_users,
      }

    rescue
      {}
    end
  end

  def get_filtered_data_counts(start_date, end_date, search_type)
    historical_date = Date.new(2016, 5, 1)
    if (start_date < historical_date) && (end_date < historical_date)
      data_counts = get_data_from_yaml(start_date, end_date)
    elsif (start_date < historical_date) && (end_date >= historical_date)
      static_data = get_data_from_yaml(start_date, historical_date - 1.day)
      dynamic_data = get_data_count(historical_date, end_date,search_type)
      data_counts = static_data.merge(dynamic_data) do |k, v1, v2|
        if %w(earned_revenue lost_revenue).include?(k.to_s)
          ('%.2f' % (v1.to_s.gsub(/[$,]/, '').to_f + v2.to_s.gsub(/[$,]/, '').to_f)).to_f
        elsif %w(closing_rate_users).include?(k.to_s)
          v1.merge(v2) do |k, v1_value, v2_value|
            v1_value.merge(v2_value) { |k, first_hash_value, second_hash_value| (first_hash_value + second_hash_value).round }
          end
        elsif v1.is_a?(Hash) || v2.is_a?(Hash)
          v1.merge(v2) { |k, v1_value, v2_value| v1_value + v2_value }
        else
          (v1.is_a?(String) ? v1.to_i : v1) + v2
        end
      end
      data_counts = percentage_data_count(data_counts)
    else
      data_counts = get_data_count(start_date, end_date, search_type)
    end

    data_counts[:earned_revenue] = number_to_currency(data_counts[:earned_revenue], :unit => '$')
    data_counts[:lost_revenue] = number_to_currency(data_counts[:lost_revenue], :unit => '$')
    data_counts
  end

  def percentage_data_count(data_count)
    data_count[:inquiry_to_appointment_total] = data_count[:total_leads] == 0 ? 0 : ('%.2f' % (data_count[:appointments].fdiv(data_count[:total_leads]) * 100)).to_f
    data_count[:closing_rate_total] = data_count[:scheduled_surgeries] == 0 ? 0 : ('%.2f' % (data_count[:completed].fdiv(data_count[:scheduled_surgeries]) * 100)).to_f
    data_count[:cancel_rate] = data_count[:scheduled_surgeries] == 0 ? 0 : ('%.2f' % (data_count[:cancelled].fdiv(data_count[:scheduled_surgeries]) * 100)).to_f
    data_count
  end

  def injector(array)
    if array.length == 0
      0
    else
      array.inject('+')
    end
  end

end
