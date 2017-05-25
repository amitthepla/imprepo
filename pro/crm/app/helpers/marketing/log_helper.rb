module Marketing::LogHelper

  def consult_status(lead_id)
    lead = @current_org.leads.find(lead_id)
    if lead.procedure_date.nil? && (lead.stage == 'cold' || lead.stage == 'disqualified')
        "<span class='text-danger'>Not Booked</span>"
    elsif lead.procedure_date.nil? && lead.stage == 'booked_consult'
        "<span class='text-warning'>Pending</span>"
    elsif !lead.procedure_date.nil? && (lead.stage == 'booked_surgery' || lead.stage = "post_op" || lead.stage = "pre_op")
        "<span class='text-success'>Booked</span>"
    end
  end

end
