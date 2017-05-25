module ApplicationHelper

  def is_admin?(user)
    user.roles.include?(user.organization.roles.where({name: 'Administrator'}).first.id.to_s)
  end
  
  def short_time_ago(time, options={})
    timestamp = time.iso8601
    dist = DateTime.now.to_i - time.to_i
    # Quick (non-i18n friendly hack to always show weeks instead of months (since "m" is ambiguous)
    message =
      if dist.to_i < 6.5.days || dist.to_i > 364.5.days
        time_ago_in_words time, locale: :en
      else
        "#{(dist/1.week).round}w"
      end
    message
    # "<time class='short-timeago timeago' locale='en_abbrev' datetime='#{timestamp}'>#{message} ago</time>".html_safe # for use with jquery timeago
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == 'asc' ? 'desc' : 'asc'
    link_to title, params.merge(:sort => column, :direction => direction, :page => nil), {:class => css_class}
  end

  def stage_label(stage)
    case stage
      when 'inquiry'
        'warning'
      when 'inquiry'
        'primary'
      when 'booked_consult'
        'info'
      when 'booked_surgery'
        'success'
      when 'post_op'
        'pink'
      when 'cold'
        'orange'
      when 'disqualified'
        'danger'
      else
        'default'
    end
  end

  def source_count_check(source_hash)
    if source_hash.present?
      source_hash["count"]
    else
      0
    end
  end

  def source_check(source_hash)
    if source_hash.present?
      source_hash["sources"]
    else
      []
    end
  end

  def get_id(user)
    if user.present?
      user.id
    end
  end


end
