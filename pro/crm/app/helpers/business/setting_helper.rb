module Business::SettingHelper
  def message_identifier(order, message)
    case order
    when "first"
      message.where(message_id: "first_email").first.message
    when "second"
      message.where(message_id: "second_email").first.message
    when "third"
      message.where(message_id: "third_email").first.message
    when "surgery"
      message.where(message_id: "surgery_email").first.message
    end
  end

  def source_dates(src)
    if src.start_date && src.end_date
      "<td style='vertical-align:middle;'>#{src.start_date ? src.start_date.strftime('%D') : 'Long Running Source'}</td> <td style='vertical-align:middle;'>#{src.end_date ? src.end_date.strftime('%D') : 'Long Running Source'}</td>".html_safe
    else
      "<td style='vertical-align:middle;'>No Established Start</td> <td style='vertical-align:middle;'>No Established End</td>".html_safe
    end
  end
end
