require 'rails_helper'

RSpec.describe "business/surgeries/index", type: :view do
  before(:each) do
    assign(:business_surgeries, [
      Business::Surgery.create!(
        :cost => 2,
        :date => "",
        :completed => "",
        :cancelled => "",
        :procedure => ""
      ),
      Business::Surgery.create!(
        :cost => 2,
        :date => "",
        :completed => "",
        :cancelled => "",
        :procedure => ""
      )
    ])
  end

  it "renders a list of business/surgeries" do
    render
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
