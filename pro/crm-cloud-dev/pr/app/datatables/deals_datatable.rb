class DealsDatatable
  include ApplicationHelper
  include DealsHelper
  include ActionView::Helpers::DateHelper
  
  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Deal.count,
      iTotalDisplayRecords: deals.total_entries,
      aaData: data(params[:_type])
    }
  end

 def get_last_task_duedate deal
     #task = Task.select("due_date").where("task_type_id=?", deal.latest_task_type_id).first
	 task = Task.select("due_date").where("deal_id =? and task_type_id=?",deal.id,deal.latest_task_type_id).not_completed.last

     return (task.due_date.strftime("%a %d %b %Y @ %H:%M") if task)
  end
private

  def data(_type)
    cuser =User.find params[:cuser]
    
    # case  _type
    # when "incoming","junk","qualify", "inactive_deals","all","no_contact","follow_up_required","follow_up","quoted","meeting_scheduled","forecasted","waiting_for_project_requirement","proposal","estimate"
      #deals.includes(:tasks, :deal_labels, :assigned_user, :initiator, :deal_status,:priority_type).includes(:deals_contacts => [{:contactable => {:address => :country }}]).map do |deal|
      #deals.includes([{:contactable=>[:deals_contacts, {:address=>:country}]}, :deals_contacts]).map do |deal|
      
     deals.includes(:last_task, :current_country,:deal_labels, :assigned_user, :initiator, :deal_status,:priority_type).includes(:deals_contacts).map do |deal|
                    
        [
          h(deal.id), #row [0]
          h(deal.title), #row [1]
          #h(format_date(deal.created_at)),
          #h(last_activity_for_deal_json_new(deal.id,cuser)[0].present? ? last_activity_for_deal_json_new(deal.id,cuser)[2]  + " ago": "N/A"), #row [2]
          h(deal.last_activity_date.present? ? distance_of_time_in_words_to_now(deal.last_activity_date)   + " ago": "N/A"), #row [2],
          #h((last_activity=distance_of_time_in_words_to_now(deal.last_activity_date)).present? ? last_activity  + " ago": "N/A"), #row [2]
          h(deal.assigned_user.present? ? ((deal.assigned_user.id == cuser.id) ? "me" : deal.assigned_user.full_name) : ''), #row [3]
          h(deal.attempts), #row [4]
          (deal.deal_labels.map{ |dlb|  [dlb.user_label.color, dlb.user_label.name,dlb.user_label_id]  }), #row [5]
		      #h(deal.collect_contact_names.present? ? deal.collect_contact_names : ""),
          #h(deal.deals_contacts.first.contactable.present? ? deal.deals_contacts.first.contactable.full_name : ""), #row [6]
          h(deal.contact_name.present? ? deal.contact_name : ""), #row [6]
          #h((deal.deals_contacts.first.contactable.present? && !deal.deals_contacts.first.contactable.phones.empty? ? deal.deals_contacts.first.contactable.phones.first.phone_no : '')), #row [7]
          h(deal.deals_contacts.present? ? (deal.deals_contacts.first.contactable.present? && deal.deals_contacts.first.contactable.phones.present? ? deal.deals_contacts.first.contactable.phones.first.phone_no : "") : ""), #row [7]
          #h((deal.deals_contacts.first.contactable.present? && !deal.deals_contacts.first.contactable.email.blank? ? deal.deals_contacts.first.contactable.email : '')), #row [8]
          h(deal.contact_email.present? ? deal.contact_email : ""), #row [8]
          h((!deal.priority_type.nil? && deal.priority_type.original_id == 1 ? 'btn-metis-1' : !deal.priority_type.nil? && deal.priority_type.original_id == 2 ? 'btn-metis-2' : 'btn-metis-3')), #row [9]
          [!deal.priority_type.nil? ? deal.priority_type.name : "NA",!deal.priority_type.nil? ? deal.priority_type.id : "NA"], #row [10]
          #h(deal.deals_contacts.first.contactable.present? && deal.deals_contacts.first.contactable.address.present? ? (deal.deals_contacts.first.contactable.address.address.present? ? deal.deals_contacts.first.contactable.address.address : '') : ''), #row [11]
          h(deal.id), #row [11]
          #h(deal.deals_contacts.first.contactable.present? && !deal.deals_contacts.first.contactable.address.nil? && !deal.deals_contacts.first.contactable.address.country.nil? ? deal.deals_contacts.first.contactable.address.country.name : ''), #row [12]
          h(deal.country_id.present? && deal.current_country.present? ? deal.current_country.name : ''), #row [12]
          #h(deal.deals_contacts.first.contactable.present? && !deal.deals_contacts.first.contactable.address.nil? ? deal.deals_contacts.first.contactable.address.city : ''), #row [13]
          h(deal.contact_loc.present? ? deal.contact_loc : ""), #row [13]
          #h(deal.deals_contacts.first.contactable.present? && deal.deals_contacts.first.contactable.id), #row [14]
          h(deal.contacts_id.present? ? deal.contacts_id : ""), #row [14]
          h(date_format(deal.created_at)),  #row [15]
          #h((deal.is_admin_created? && !cuser.is_admin?) ? true : false),
          h((deal.associated_users.include? cuser.id) || (cuser.is_admin? || cuser.is_super_admin?) ? true : false),  #row [16]
          h(!deal.amount.nil? ? deal.amount.to_i : ''), #row [17]
          #h(( deal.deals_contacts &&  deal.deals_contacts.first.contactable && deal.deals_contacts.first.contactable.is_company?) ? "company_contact" : "individual_contact"), #row [18]
          h(deal.contact_type.present? ? deal.contact_type : ""), #row [18]
          h(deal.assigned_to), #row [19]
          h(deal.initiated_by), #row [20]
          h((deal.initiated_by == cuser.id) || (cuser.is_admin?) ? true : false), #row [21]
          h(deal.deal_status_id), #row [22]
          #h( (deal.deals_contacts &&  deal.deals_contacts.first.contactable && deal.deals_contacts.first.contactable.is_company? )? "" : h(deal.collect_company_designaion)), #row [23]
          h(deal.compdesignation.present? ? deal.compdesignation : ""), #row [23]
          h(deal.initiator.present? ? (deal.initiated_by == cuser.id ? "me" : deal.initiator.first_name) : ""), #row [24]
          h(deals.total_entries), #row [25]
          h(deal.deal_status_name), #row [26]
          #h((deal.tasks.last.present? && deal.tasks.last.task_type.present? && !deal.tasks.last.is_completed?) ? deal.tasks.last.task_type.name : "No-Action")#row [27]
          #h((deal.tasks.first.present?) ? (deal.tasks.not_completed.last.present? ? deal.tasks.not_completed.last.task_type.name : "No-Action") : "No-Action"),          
          h(deal.last_task.present? ? deal.last_task.name  : "No-Action"),
          #h((deal.tasks.first.present?) ? (deal.tasks.select("due_date").not_completed.last.present? ? deal.tasks.select("due_date").not_completed.last.due_date.strftime("%a %d %b %Y @ %H:%M") : "") : "")
          h(deal.latest_task_type_id.present? ? get_last_task_duedate(deal)  : ""),
          h(deal.is_opportunity),
          !deal.deal_status.nil? ? deal.deal_status.original_id : "NA" ,
          h(deal.user_label.present? ? deal.user_label.name : "Uncategorised"), #row[31]
          h(deal.get_color_code(deal.contact_name.downcase[0])), #row[32]
          h(deal.deals_contacts.present? ? deal.deals_contacts.first.contactable.to_param : ""), #row[33]
          h(deal.deals_contacts.present? && deal.deals_contacts.first.contactable.image.present? ? deal.deals_contacts.first.contactable.image.image.url(:icon) : ""), #row[34]
          h(deal.to_param), #row[35]
          h(deal.deals_contacts.present? && deal.deals_contacts.first.contactable.present? ? deal.deals_contacts.first.contactable.class.name : "")
        ]

      end
  end
  
  def move_date deal
    p deal
    p deal.id
    p deal.stage_move_date
    puts "_)_)__)_)_)_)_)_)_)_)_)_)_)_)_)_)_)_)_)_)_)_)_)_)_)_)_)"
    deal.stage_move_date.strftime("%b %d, %Y") if deal.stage_move_date.present?
  end
  
  def deals
  puts "coming to datatable"
    @deals ||= fetch_deals
  end


  def fetch_deals
    cuser =User.find params[:cuser]
    filtervalue = params[:filtervalue]
    filtertype = params[:filtertype]
    cre_by = params[:cre_by]
    cre_by_val = params[:cre_by_val]
    asg_by = params[:asg_by]
    asg_by_val = params[:asg_by_val]
    loc = params[:loc]
    loc_val = params[:loc_val]
    priority = params[:priority]
    priority_val = params[:priority_val]
    next_t = params[:next]
    next_val = params[:next_val]
    daterange = params[:daterange]
    dt_range = params[:dt_range]
    stage = params[:stage]
    stage_val = params[:stage_val]   
    if(params[:q] == "1")
      @start_date = DateTime.new(params[:y].to_i,1,1)
      @end_date = DateTime.new(params[:y].to_i,3,31)     
    elsif(params[:q] == "2")
      @start_date = DateTime.new(params[:y].to_i,4,1)
      @end_date = DateTime.new(params[:y].to_i,6,30)     
    elsif(params[:q] == "3")
      @start_date = DateTime.new(params[:y].to_i,7,1)
      @end_date = DateTime.new(params[:y].to_i,9,30)     
    elsif(params[:q] == "4")
     @start_date = DateTime.new(params[:y].to_i,10,1)
     @end_date = DateTime.new(params[:y].to_i,12,31)     
    end

      @dls=[]
      if !params[:ds_id].present? && params[:ds_id] != "undefined"
        if params[:three_months].present?          
          if(cuser.is_super_admin? || cuser.is_admin?)
           @dls = cuser.organization.deals.last_three_months.includes(:deal_status).where(:is_active=>true).where("deal_statuses.original_id IN (?) ", status=[1])
          else
           @dls = @cuser.all_assigned_deal.last_three_months.includes(:deal_status).where(:is_active=>true).where("deal_statuses.original_id IN (?) ", status=[1])
          end
        elsif active_multifilter?
          params[:assigned_to]=nil
          params[:created_by]=nil
          @dls = cuser.organization.deals.active_multi_filter(params)
          @dls=@dls.where(:is_active=>true) if @dls.present?        
        else
          if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
            @dls = cuser.organization.deals.by_label(filtervalue).where(:is_active=>true)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
            @dls = cuser.organization.deals.by_priority(filtervalue).where(:is_active=>true)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "stage")
            @dls = cuser.organization.deals.by_stage(filtervalue).where(:is_active=>true)
          else
            @dls = cuser.organization.deals.where(:is_active=>true)
          end
        end
      else
        if active_multifilter?
          params[:assigned_to]=nil
          params[:created_by]=nil
          @dls = cuser.organization.deals.active_multi_filter(params)
          @dls=@dls.where(:is_active=>true,:deal_status_id=>cuser.organization.filter_deal_status(params[:ds_id],cuser.organization.id).id) if @dls.present?
        else
          if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
            @dls = cuser.organization.deals.by_label(filtervalue).where(:is_active=>true,:deal_status_id=>cuser.organization.filter_deal_status(params[:ds_id],cuser.organization.id).id)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
            @dls = cuser.organization.deals.by_priority(filtervalue).where(:is_active=>true,:deal_status_id=>cuser.organization.filter_deal_status(params[:ds_id],cuser.organization.id).id)
          else
            @dls = cuser.organization.deals.where(:is_active=>true,:deal_status_id=>cuser.organization.filter_deal_status(params[:ds_id],cuser.organization.id).id)
          end
        end
      end

    if params[:filtervalue] == "opportunity"
     @dls = @dls.where(:is_opportunity=>true)
    end
     if params[:tag].present?
       @dls = @dls.tagged_with(params[:tag])
     end

     puts "------------------------------------- ++++++++++++++ #{sort_column}"
     p sort_column
    if(sort_column == "title" || sort_column == "country_id" || sort_column == "created_at" || sort_column == "stage_move_date" || sort_column == "amount" || sort_column == "priority_type_id" || sort_column == "deal_status_id"  )
     deals = @dls.reorder(nil).order("#{sort_column} #{sort_direction}").page(page).per_page(per_page)
    else
      deals = @dls.order("last_activity_date desc").order("#{sort_column} #{sort_direction}").page(page).per_page(per_page)
    end
  
   deals = deals.page(page).per_page(per_page)

    if params[:sSearch].present?
      deals = deals.where("title like :search ", search: "%#{params[:sSearch]}%")
    end
    deals
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

 def sort_column
    if params[:_type] == "all"
	   #columns = %w[deals.id title created_at country_id deal_status_id amount amount priority_type_id]
	   columns = %w[deals.id title created_at country_id deal_status_id amount amount priority_type_id priority_type_id]
    else
      columns = %w[deals.id title id country_id created_at id priority_type_id]
    end
    columns[params[:iSortCol_0].to_i]
    puts "---------------------------- columns"
    p columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
  
  private
  def active_multifilter?
    params[:cre_by].present? || params[:cre_by_val].present? || params[:asg_by].present? || params[:asg_by_val].present? || params[:loc].present? || params[:loc_val].present? || params[:priority].present? || params[:priority_val].present?|| params[:next].present? || params[:next_val].present? || params[:daterange].present? || params[:dt_range].present? || params[:last_touch].present? || params[:last_tch].present?  || params[:dt_range_from].present? || params[:dtrange_from].present? || params[:dtrange_to].present? || params[:dt_range_to].present? || params[:is_opportunity].present? || params[:tag].present? || params[:stage].present? || params[:stage_val].present? || params[:user_label].present? || params[:user_label_val].present? || params[:label_type].present?
  end
end