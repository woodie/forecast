require "rails_helper"

RSpec.describe WeatherHelper, type: :helper do
  describe "#icon_url" do
    let(:code) { "13d" }
    let(:tag) { '<img alt="icon" title="icon" class="weather-icon" src="/ow/13d@2x.png" />' }
    it "returns populated IMG tag" do
      expect(helper.icon_url(code)).to eq tag
    end
  end

  describe "#time_format" do
    let(:datetime) { 1732656764 }
    context "with West Coast location" do
      let(:timezone) { -28800 }
      it "returns formated string" do
        expect(helper.time_format(datetime, timezone)).to eq "1:32pm"
      end
    end

    context "with East Coast location" do
      let(:timezone) { -18000 }
      it "returns formated string" do
        expect(helper.time_format(datetime, timezone)).to eq "4:32pm"
      end
    end
  end

  describe "#temp_format" do
    context "with fahrenheit country" do
      let(:country_code) { "us" }
      it "returns formated string" do
        expect(helper.temp_format(300, country_code)).to eq "80°F"
      end
    end

    context "with celsius country" do
      let(:country_code) { "jp" }
      it "returns formated string" do
        expect(helper.temp_format(300, country_code)).to eq "27°C"
      end
    end
  end

  describe "#to_celsius" do
    it "returns converted float" do
      expect(helper.send(:to_celsius, 300)).to eq 26.85
    end
  end

  describe "#to_fahrenheit" do
    it "returns converted float" do
      expect(helper.send(:to_fahrenheit, 300)).to eq 80.33
    end
  end
end
