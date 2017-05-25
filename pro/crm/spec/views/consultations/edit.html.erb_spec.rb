require 'rails_helper'

RSpec.describe "consultations/edit", type: :view do
  before(:each) do
    @consultation = assign(:consultation, Consultation.create!(
      :lead => nil,
      :date => "",
      :cancelled => "",
      :no_show => "",
      :cost => ""
    ))
  end

  it "renders the edit consultation form" do
    render

    assert_select "form[action=?][method=?]", consultation_path(@consultation), "post" do

      assert_select "input#consultation_lead_id[name=?]", "consultation[lead_id]"

      assert_select "input#consultation_date[name=?]", "consultation[date]"

      assert_select "input#consultation_cancelled[name=?]", "consultation[cancelled]"

      assert_select "input#consultation_no_show[name=?]", "consultation[no_show]"

      assert_select "input#consultation_cost[name=?]", "consultation[cost]"
    end
  end
end
