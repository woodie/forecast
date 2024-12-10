require 'rails_helper'

RSpec.describe "addresses/show", type: :view do
  let(:place) { Place.create! }
  before(:each) do
    assign(:address, Address.create!(
      query: "Query",
      place: place
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Query/)
    expect(rendered).to match(//)
  end
end
