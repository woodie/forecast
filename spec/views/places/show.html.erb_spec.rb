require 'rails_helper'

RSpec.describe "places/show", type: :view do
  before(:each) do
    assign(:place, Place.create!(
      city: "City",
      state: "State",
      country: "Country",
      country_code: "Country Code",
      postal_code: "Postal Code",
      lat: 2.5,
      lon: 3.5,
      current_weather: "",
      weather_forecast: ""
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/City/)
    expect(rendered).to match(/State/)
    expect(rendered).to match(/Country/)
    expect(rendered).to match(/Country Code/)
    expect(rendered).to match(/Postal Code/)
    expect(rendered).to match(/2.5/)
    expect(rendered).to match(/3.5/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
