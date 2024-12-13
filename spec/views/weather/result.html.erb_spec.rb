require "rails_helper"

RSpec.describe "weather/result", type: :view do
  let(:data) {
    {"weather" => [{"description" => "fun", "icon" => "13d"}],
     "main" => {"temp" => 284.26, "temp_min" => 283.15,
                "feels_like" => 283.70, "temp_max" => 284.82},
     "dt" => 1732656764, "timezone" => -28800}
  }
  let(:list) { {"list" => Array.new(40) { data }} }
  before(:each) do
    assign(:place, Place.create!(
      city: "Truckee",
      state: "California",
      country: "United States",
      country_code: "US",
      postal_code: 96161,
      current_weather: data,
      weather_forecast: list
    ))
  end

  it "renders attributes" do
    render
    expect(rendered).to match(/Truckee, California/)
    expect(rendered).to match(/96161, United States/)
    expect(rendered).to match(/fun/)
    expect(rendered).to match(/13d/)
    expect(rendered).to match(/Weather data from 1:32pm/)
    expect(rendered).to match(/50°F/)
    expect(rendered).to match(/51°F/)
    expect(rendered).to match(/52°F/)
    expect(rendered).to match(/53°F/)
  end
end
