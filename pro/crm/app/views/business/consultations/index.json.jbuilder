json.array!(@consultations) do |consultation|
  json.extract! consultation, :id, :lead_id, :date, :cancelled, :no_show, :cost
  json.url consultation_url(consultation, format: :json)
end
