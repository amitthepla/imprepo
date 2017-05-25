json.array!(@events) do |event|
  json.extract! event, :id, :description
  json.title "#{event.contact.full_name} - #{event.type}"
  json.start event.start_time
  json.end event.end_time
  json.stage event.contact.leads.last.stage
end