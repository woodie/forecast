require "rails_helper"

RSpec.describe "weather/result", type: :view do
  before { assign(:place, build(:populated_place)) }

  it "renders attributes" do
    render
    expect(rendered).to match(/Truckee, California/)
    expect(rendered).to match(/96161, United States/)
  # expect(rendered).to match(/Snow/)
  # expect(rendered).to match(/13d/)
    expect(rendered).to match(/Weather data from 1:32pm/)
    expect(rendered).to match(/50°F/)
    expect(rendered).to match(/51°F/)
    expect(rendered).to match(/52°F/)
    expect(rendered).to match(/53°F/)
  end
end
