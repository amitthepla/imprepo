json.array!(@business_surgeries) do |business_surgery|
  json.extract! business_surgery, :id, :cost, :date, :completed, :cancelled, :procedure
  json.url business_surgery_url(business_surgery, format: :json)
end
