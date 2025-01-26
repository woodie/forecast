require "rails_helper"

RSpec.describe WeatherImage, type: :model do
  describe "MAP constant" do
    it "values map to all known text values" do
      expect(WeatherImage::MAP.keys.sort).to match WeatherIcon::ICON_ID.keys.sort
    end
  end

  describe "#image" do
    let(:code) { "Fog" }

    subject { WeatherImage.image(code, is_day) }

    context "when is_day is nil" do
      let(:is_day) { nil }

      it "returns neutral label" do
        expect(subject).to eq "fog"
      end
    end

    context "when is_day is true" do
      let(:is_day) { true }

      it "returns day label" do
        expect(subject).to eq "fog-day"
      end
    end

    context "when is_day is false" do
      let(:is_day) { false }

      it "returns night label" do
        expect(subject).to eq "fog-night"
      end
    end
  end
end
