require 'rails_helper'

RSpec.describe "places/edit", type: :view do
  let(:place) {
    Place.create!(
      city: "MyString",
      state: "MyString",
      country: "MyString",
      country_code: "MyString",
      postal_code: "MyString",
      lat: 1.5,
      lon: 1.5,
      current_weather: "",
      weather_forecast: ""
    )
  }

  before(:each) do
    assign(:place, place)
  end

  it "renders the edit place form" do
    render

    assert_select "form[action=?][method=?]", place_path(place), "post" do

      assert_select "input[name=?]", "place[city]"

      assert_select "input[name=?]", "place[state]"

      assert_select "input[name=?]", "place[country]"

      assert_select "input[name=?]", "place[country_code]"

      assert_select "input[name=?]", "place[postal_code]"

      assert_select "input[name=?]", "place[lat]"

      assert_select "input[name=?]", "place[lon]"

      assert_select "input[name=?]", "place[current_weather]"

      assert_select "input[name=?]", "place[weather_forecast]"
    end
  end
end
