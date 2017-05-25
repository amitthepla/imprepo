json.array!(@leads) do |lead|
  json.extract! lead, :id, :first_name, :last_name, :email, :phone, :stage, :created_at
  json.lead_id "#{lead.id}"
  json.date "#{lead.created_at.strftime('%D')}"
  json.lead_stage "#{lead.stage.titleize}"

end
