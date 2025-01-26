require "rails_helper"

RSpec.describe WeatherHelper, type: :helper do
  describe "#icon_tag" do
    let(:code) { "13d" }
    let(:src) { "https://openweathermap.org/img/wn/#{code}@2x.png" }
    let(:tag) { "<img alt=\"icon\" title=\"icon\" class=\"\" src=\"#{src}\" />" }
    it "returns populated IMG tag" do
      expect(helper.icon_tag(code)).to eq tag
    end
  end

  describe "#icon_css" do
    let(:id) { 800 }
    let(:opt) { {"id" => id, "icon" => icon} }

    context "with a day icon" do
      let(:icon) { "01d" }
      it "returns wi day class" do
        expect(helper.icon_css(opt)).to eq "wi wi-owm-day-800"
      end
    end

    context "with a night icon" do
      let(:icon) { "01n" }
      it "returns wi night class" do
        expect(helper.icon_css(opt)).to eq "wi wi-owm-night-800"
      end

      context "with neutral-only id" do
        let(:id) { 602 }
        it "returns wi neutral class" do
          expect(helper.icon_css(opt)).to eq "wi wi-owm-602"
        end
      end

      context "with neutral is forced" do
        it "returns wi neutral class" do
          expect(helper.icon_css(opt, true)).to eq "wi wi-owm-800"
        end
      end
    end
  end

  describe "#time_format" do
    let(:datetime) { 1732656764 }
    context "with West Coast location" do
      let(:timezone) { "America/Los_Angeles" }
      it "returns formated string" do
        expect(helper.time_format(datetime, timezone)).to eq "1:32pm"
      end
    end

    context "with East Coast location" do
      let(:timezone) { "America/New_York" }
      it "returns formated string" do
        expect(helper.time_format(datetime, timezone)).to eq "4:32pm"
      end
    end
  end

  describe "#temp_format" do
    context "when passed nil" do
      it "returns n/a" do
        expect(helper.temp_format(nil, "us")).to eq "n/a"
      end
    end

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
