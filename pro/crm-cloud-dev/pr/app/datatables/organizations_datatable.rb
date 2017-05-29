  class OrganizationsDatatable
  include ApplicationHelper
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: organizations_info.count,
      iTotalDisplayRecords: organizations.total_entries,
      aaData: data
    }
  end

private

  def organizations_info
    Organization.organization_list
  end
  def get_last_activity(org)
    org_activities = org.activities
    if org_activities.present? && dt = org_activities.last.created_at
      today = Time.zone.now.strftime('%Y-%m-%d')
      yesterday = (Time.zone.now - (24 * 60 * 60)).strftime('%Y-%m-%d')
      day_before_yesterday = (Time.zone.now - (48 * 60 * 60)).strftime('%Y-%m-%d')
      if (Date.today.to_s == DateTime.parse(dt.to_s).strftime('%Y-%m-%d').to_s)
        "Today #{DateTime.parse(dt.to_s).strftime('%H:%M %p').to_s}"
      else
        if (yesterday.to_s == DateTime.parse(dt.to_s).strftime('%Y-%m-%d').to_s)
          "Yesterday #{DateTime.parse(dt.to_s).strftime('%H:%M %p').to_s}"
        else
          if (yesterday.to_s == DateTime.parse(dt.to_s).strftime('%Y-%m-%d').to_s)
            "Yesterday #{DateTime.parse(dt.to_s).strftime('%H:%M %p').to_s}"
          else
            dt.strftime("%b %d, %Y %H:%M %p")
          end
        end
      end
    end
  end

  def data
    organizations.map do |organization|
      google_users = organization.users.select {|r| r.provider.include?("google") if r.provider.present? }.count
      linkedin_users = organization.users.select {|r| r.provider.include?("linkedin") if r.provider.present? }.count
      regular_users = organization.users.select {|r| r.provider.nil? }.count
      [
        h(organization.id), #row[0]
        h(organization.name), #row[1]
        h(organization.email.present? ? organization.email : "N/A"), #row[2]
        h(organization.created_at.strftime("%b %d, %Y")), #row[3]
        h(organization.users.first.present? ? organization.users.first.time_zone.present? ? organization.users.first.time_zone : "N/A" : "N/A"), #row[4]
        h("Google (" + google_users.to_s + "), Linkedin (" + linkedin_users.to_s + "), Regular (" + regular_users.to_s + ")"), #row[5]
        h(get_last_activity(organization).present? ? get_last_activity(organization) : "N/A"), #row[6]
        h(organization.total_users.present? ? organization.total_users : 0),  #row[7]
        h(organization.deals.count), #row[8]
        h(organization.contacts.count), #row[9]
        h(organization.tasks.count) #row[10]
      ]
    end
  end
  
  def organizations
    @sources ||= fetch_organizations
  end

  def fetch_organizations
    organizations = organizations_info
    organizations = organizations.page(page).per_page(per_page)
    if params[:sSearch].present?
      organizations = organizations.where("(name like :search)", search: "%#{params[:sSearch]}%")
    end
    organizations
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[title]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
