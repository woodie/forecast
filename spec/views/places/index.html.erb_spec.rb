require 'rails_helper'

RSpec.describe "places/index", type: :view do
  before(:each) do
    assign(:places, [
      Place.create!(
        city: "City",
        state: "State",
        country: "Country",
        country_code: "Country Code",
        postal_code: "Postal",
        lat: 2.5,
        lon: 3.5,
        current_weather: "{current: 'one'}",
        weather_forecast: "{forwcast: 'two'}"
      ),
      Place.create!(
        city: "City",
        state: "State",
        country: "Country",
        country_code: "Country Code",
        postal_code: "Postal",
        lat: 2.5,
        lon: 3.5,
        current_weather: "{current: 'one'}",
        weather_forecast: "{forwcast: 'two'}"
      )
    ])
  end

  it "renders a list of places" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("City".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("State".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Country".to_s), count: 4
    assert_select cell_selector, text: Regexp.new("Code".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Postal".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(2.5.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(3.5.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("{current: 'one'}".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("{forwcast: 'two'}".to_s), count: 2
  end
end
