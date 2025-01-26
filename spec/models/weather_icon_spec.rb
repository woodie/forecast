require "rails_helper"

RSpec.describe WeatherIcon, type: :model do
  subject { WeatherIcon }

  describe "OW_ICON constant" do
    it "values map to all known text values" do
      expect(subject::OW_ICON.values.uniq.sort << 50).to match subject::OW_TEXT.values
    end
  end

  describe "#icon" do
    it "returns Open Weather icon" do
      expect(subject.icon("Clear")).to eq "01d"
      expect(subject.icon("Clear", false)).to eq "01n"
      expect(subject.icon("Snow")).to eq "13d"
      expect(subject.icon("Snow", false)).to eq "13n"
      expect(subject.icon("Dust")).to eq "50d"
      expect(subject.icon("Dust", false)).to eq "50n"
    end
  end
end
