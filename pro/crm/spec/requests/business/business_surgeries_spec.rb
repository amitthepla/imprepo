require 'rails_helper'

RSpec.describe "Business::Surgeries", type: :request do
  describe "GET /business_surgeries" do
    it "works! (now write some real specs)" do
      get business_surgeries_path
      expect(response).to have_http_status(200)
    end
  end
end
