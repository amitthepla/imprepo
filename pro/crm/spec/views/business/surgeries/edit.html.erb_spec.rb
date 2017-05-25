require 'rails_helper'

RSpec.describe "business/surgeries/edit", type: :view do
  before(:each) do
    @business_surgery = assign(:business_surgery, Business::Surgery.create!(
      :cost => 1,
      :date => "",
      :completed => "",
      :cancelled => "",
      :procedure => ""
    ))
  end

  it "renders the edit business_surgery form" do
    render

    assert_select "form[action=?][method=?]", business_surgery_path(@business_surgery), "post" do

      assert_select "input#business_surgery_cost[name=?]", "business_surgery[cost]"

      assert_select "input#business_surgery_date[name=?]", "business_surgery[date]"

      assert_select "input#business_surgery_completed[name=?]", "business_surgery[completed]"

      assert_select "input#business_surgery_cancelled[name=?]", "business_surgery[cancelled]"

      assert_select "input#business_surgery_procedure[name=?]", "business_surgery[procedure]"
    end
  end
end
