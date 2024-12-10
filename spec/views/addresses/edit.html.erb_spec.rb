require 'rails_helper'

RSpec.describe "addresses/edit", type: :view do
  let(:place) { Place.create! }
  let(:address) {
    Address.create!(
      query: "MyString",
      place: place
    )
  }

  before(:each) do
    assign(:address, address)
  end

  it "renders the edit address form" do
    render

    assert_select "form[action=?][method=?]", address_path(address), "post" do

      assert_select "input[name=?]", "address[query]"

      assert_select "input[name=?]", "address[place_id]"
    end
  end
end
