require 'rails_helper'

RSpec.describe "consultations/index", type: :view do
  before(:each) do
    assign(:consultations, [
      Consultation.create!(
        :lead => nil,
        :date => "",
        :cancelled => "",
        :no_show => "",
        :cost => ""
      ),
      Consultation.create!(
        :lead => nil,
        :date => "",
        :cancelled => "",
        :no_show => "",
        :cost => ""
      )
    ])
  end

  it "renders a list of consultations" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
