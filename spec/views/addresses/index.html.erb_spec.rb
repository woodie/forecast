require 'rails_helper'

RSpec.describe "addresses/index", type: :view do
  let(:place) { Place.create! }

  before(:each) do
    assign(:addresses, [
      Address.create!(
        query: "Query",
        place: place
      ),
      Address.create!(
        query: "Query",
        place: place
      )
    ])
  end

  it "renders a list of addresses" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Query".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(place.id.to_s), count: 2
  end
end
