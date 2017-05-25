module Business::ContactHelper
  def confirm_info(info)
    if !info.present?
      "Did Not Answer"
    else
      info.titleize
    end
  end

  def account_rep_contact(contact)
    @current_org.users.find(contact.account_rep_id).full_name
  end

  def reminders(contact)
    contact.leads.map { |lead| lead.tasks.incomplete_tasks.all.to_a }.flatten
  end

  def converted_inquiries(contact)
    contact.leads.where(surgery_complete: true)
  end

  def is_admin?(user)
    user.roles.include?(user.organization.roles.where({name: 'Administrator'}).first.id.to_s)
  end
end
