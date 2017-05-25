module Business::LeadHelper

  def answer?(lead_info)
    [nil, "", " "].include?(lead_info) ? "Did Not Answer" : lead_info
  end

  def get_name( user)
    if user.present?
      user.full_name
    end
  end

  def planned_surgery_date(date)
    month_no = date.to_s.split('/').first.to_i
    year = date.to_s.split('/').last
    month_name = Date::MONTHNAMES[month_no]
    "#{month_name} / #{year}"
  end

  def reply_from(note)
    from = note.reply_from
    user = note.user
    str = ''
    if from == 'lead'
      str = '&nbsp;-&nbsp; Reply From Lead'
    elsif from == 'staff'
      if user
        # str = "&nbsp;-&nbsp; Reply From #{user.full_name} (#{user.role.name})"
        str = "&nbsp;-&nbsp; Reply From #{user.full_name} (#{@current_org.roles.find(user.roles.first).name})"
      else
        str = '&nbsp;-&nbsp; Reply From Sales Coordinator'
      end
    end
    str.html_safe
  end

  def render_stage_specific_action(stage_id, lead_id)
    case stage_id
    when 'inquiry'
      raw "<a href='consultations/book/#{lead_id}' data-target='#modal' data-dismiss='modal' aria-hidden='true' data-remote='true' class='btn btn-xs btn-success' role='button' data-toggle='modal'>Book Consult</a>"
    when 'booked_consult'
      raw "<a href='surgeries/book/#{lead_id}' data-target='#modal' data-dismiss='modal' aria-hidden='true' data-remote='true' class='btn btn-xs btn-success' role='button' data-toggle='modal'>Book Surgery</a>"
    end
  end

  def currency_helper(string)
    if string.include?('$')
      string
    else
      number_to_currency(string)
    end
  end

  def pictures(lead)
    if lead.lead_photos.present?
      "<span class='text-success'><i class='text-success fa fa-camera' aria-hidden='true'></i> #{lead.lead_photos.count}</span>".html_safe
    elsif lead.photos_requested
      "<span class='label label-md label-warning'>Request Sent</span>".html_safe
    else
      "<a href='/send_photo_request/#{lead.id}' class='btn btn-xs btn-info' data-remote ='true'>Request Photos</a>".html_safe
    end
  end

  def profile(lead)
    if lead.contact && lead.contact.questionnaire.questionnaire_filled
      "<span class='label label-md label-success'>Profile Completed</span>".html_safe
    elsif lead.photos_requested
      "<span class='label label-md label-warning'>Request Sent</span>".html_safe
    else
      "<a href='/send_beauty_profile/#{lead.id}' class='btn btn-xs btn-info' data-remote ='true'>Request Profile</a>".html_safe
    end
  end

  def last_seen(lead)
    if !lead.activities.where({:body => /viewed lead./}).last.nil?
      time = lead.activities.where({:body => /viewed lead./}).last.created_at
      "<span class='text-success'><i class='text-success fa fa-eye fa-lg' aria-hidden='true'></i>  #{short_time_ago(time)} ago</span>".html_safe
    else
      "<span class='text-danger'><i class='text-danger fa fa-eye-slash fa-lg' aria-hidden='true'></i></span>".html_safe
    end
  end

  def is_admin?(user)
    user.roles.include?(user.organization.roles.where({name: 'Administrator'}).first.id.to_s)
  end

  def status(lead)
      if lead.lead_photos.count > 0 || lead.questionnaire_filled == true
        '<span style="font-size:20px;" class="text-danger glyphicon glyphicon-fire"></span>'.html_safe
      elsif (Date.today - lead.created_at.to_date).to_i > 18
        '<i class=" text-info fa fa-snowflake-o fa-2x" aria-hidden="true"></i>'.html_safe
      else
        '<i class=" text-warning fa fa-thermometer-full fa-2x" aria-hidden="true"></i>'.html_safe
      end
  end

  def headers(stage)

    case stage
    when "inquiry"
      headers = ["NAME","ACTIVITY","PHOTOS","PROFILE","COORDINATOR","PROCEDURE","INQUIRED ON","TIME FRAME","ACTION"]
    when "booked_consult"
      headers = ["NAME","ACTIVITY","PHOTOS","PROFILE","COORDINATOR","PROCEDURE","CONSULT DATE","TIME FRAME","ACTION"]
    when "booked_surgery"
      headers = ["NAME","ACTIVITY","PHOTOS","PROFILE","COORDINATOR","PROCEDURE","PROCEDURE DATE","PRICE"]
    when "post_op"
      headers = ["NAME","COORDINATOR","PROCEDURE","PROCEDURE DATE","PRICE"]
    else
      headers = ["NAME","ACTIVITY","PHOTOS","PROFILE","COORDINATOR","PROCEDURE","INQUIRED ON","BUDGET"]
    end
    headers

  end

  def rows(stage,lead)
    case stage
    when "inquiry"
      headers = [
                  "<td><a href='/leads/#{lead.id}'>#{lead.name}</a></td>",
                  "<td>#{last_seen(lead)}</td>",
                  "<td id='photo_#{lead.id}'>#{pictures(lead)}</td>",
                  "<td id='profile_#{lead.id}'>#{profile(lead)}</td>",
                  "<td>#{lead.user.full_name if lead.user}</td>",
                  "<td>#{lead.interested_in ? lead.interested_in.titleize.upcase : 'Not Specified'}</td>",
                  "<td>#{lead.created_at.strftime("%a %b %e")} at #{lead.created_at.strftime("%I:%M %p")}</td>",
                  "<td>#{lead.contact ? lead.contact.questionnaire.planned_surgery_date : "Not Answered"}</td>",
                  "<td>#{render_stage_specific_action(stage, lead.id)}</td>"
                ]
    when "booked_consult"
      headers = [
                  "<td><a href='/leads/#{lead.id}'>#{lead.name}</a></td>",
                  "<td>#{last_seen(lead)}</td>",
                  "<td id='photo_#{lead.id}'>#{pictures(lead)}</td>",
                  "<td id='profile_#{lead.id}'>#{profile(lead)}</td>",
                  "<td>#{lead.user.full_name if lead.user}</td>",
                  "<td>#{lead.interested_in ? lead.interested_in.titleize.upcase : 'Not Specified'}</td>",
                  "<td>#{(lead.consultation.date ? lead.consultation.date.strftime("%m/%d/%Y") : 'Not Set') unless lead.consultation.nil?}</td>",
                  "<td>#{lead.contact ? lead.contact.questionnaire.planned_surgery_date : "Not Answered"}</td>",
                  "<td>#{render_stage_specific_action(stage, lead.id)}</td>"
                ]
    when "booked_surgery"
      headers = [
                  "<td><a href='/leads/#{lead.id}'>#{lead.name}</a></td>",
                  "<td>#{last_seen(lead)}</td>",
                  "<td id='photo_#{lead.id}'>#{pictures(lead)}</td>",
                  "<td id='profile_#{lead.id}'>#{profile(lead)}</td>",
                  "<td>#{lead.user.full_name if lead.user}</td>",
                  "<td>#{(lead.surgery.procedure ? lead.surgery.procedure.titleize : 'Not Specified') unless lead.surgery.nil?}</td>",
                  "<td>#{(lead.surgery.date ? lead.surgery.date.strftime("%m/%d/%Y") : 'Not Set') unless lead.surgery.nil?}</td>",
                  "<td>#{(currency_helper(lead.surgery.cost.to_s)) unless lead.surgery.nil?}</td>"
                ]
    when "post_op"
      headers = [
                  "<td><a href='/leads/#{lead.id}'>#{lead.name}</a></td>",
                  "<td>#{lead.user.full_name if lead.user}</td>",
                  "<td>#{(lead.surgery.procedure ? lead.surgery.procedure.titleize : 'Not Specified') unless lead.surgery.nil?}</td>",
                  "<td>#{(lead.surgery.date ? lead.surgery.date.strftime("%m/%d/%Y") : 'Not Set') unless lead.surgery.nil?}</td>",
                  "<td>#{(currency_helper(lead.surgery.cost.to_s)) unless lead.surgery.nil?}</td>"
                ]
    else
      headers = [
                  "<td><a href='/leads/#{lead.id}'>#{lead.name}</a></td>",
                  "<td>#{last_seen(lead)}</td>",
                  "<td id='photo_#{lead.id}'>#{pictures(lead)}</td>",
                  "<td id='profile_#{lead.id}'>#{profile(lead)}</td>",
                  "<td>#{lead.user.full_name if lead.user}</td>",
                  "<td>#{lead.interested_in ? lead.interested_in.titleize.upcase : 'Not Specified'}</td>",
                  "<td>#{lead.created_at.strftime("%a %b %e")} at #{lead.created_at.strftime("%I:%M %p")}</td>"
                ]
    end
    headers
  end

  def created_by(string)
    user = User.where(id: string).first
    if user
      user.full_name
    else
      string
    end
  end

end
