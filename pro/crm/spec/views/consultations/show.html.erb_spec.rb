require 'rails_helper'

RSpec.describe "consultations/show", type: :view do
  before(:each) do
    @consultation = assign(:consultation, Consultation.create!(
      :lead => nil,
      :date => "",
      :cancelled => "",
      :no_show => "",
      :cost => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
