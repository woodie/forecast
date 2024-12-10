require 'rails_helper'

RSpec.describe "addresses/new", type: :view do
  let(:place) { Place.create! }
  before(:each) do
    assign(:address, Address.new(
      query: "MyString",
      place: place
    ))
  end

  it "renders new address form" do
    render

    assert_select "form[action=?][method=?]", addresses_path, "post" do

      assert_select "input[name=?]", "address[query]"

      assert_select "input[name=?]", "address[place_id]"
    end
  end
end
