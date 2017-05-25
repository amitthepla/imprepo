require 'rails_helper'

RSpec.describe "business/surgeries/show", type: :view do
  before(:each) do
    @business_surgery = assign(:business_surgery, Business::Surgery.create!(
      :cost => 2,
      :date => "",
      :completed => "",
      :cancelled => "",
      :procedure => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
