require "rails_helper"

RSpec.describe Place, type: :model do
  describe ".geo_create" do
    let(:state) { nil }
    let(:district) { nil }
    let(:province) { nil }
    let(:geo) {
      double("GeocoderResult",
        data: {"address" => {"district" => district, "province" => province}},
        city: "Truckee", state: state, postal_code: "96161",
        country: "United States", country_code: "us",
        latitude: "40.1234", longitude: "-120.1234")
    }

    subject { Place.geo_create(geo) }

    it "uses result attributes" do
      expect(subject.state).to be_nil
      expect(subject.city).to eq("Truckee")
      expect(subject.country).to eq("United States")
      expect(subject.postal_code).to eq("96161")
      expect(subject.country_code).to eq("us")
      expect(subject.lat).to eq(40.1234)
      expect(subject.lon).to eq(-120.1234)
    end

    context "when state present" do
      let(:state) { "State" }
      it "uses state" do
        expect(subject.state).to eq(state)
      end
    end

    context "when district present" do
      let(:district) { "District" }
      it "uses district" do
        expect(subject.state).to eq(district)
      end
    end

    context "when province present" do
      let(:province) { "Province" }
      it "uses province" do
        expect(subject.state).to eq(province)
      end
    end
  end

  describe "#refresh_weather" do
    let(:place) { build(:place, current_weather: current, weather_forecast: forecast, updated_at: updated_at) }
    let(:cz) { {country_code: "us", zipcode: "96161"} }
    let(:ll) { {:lat=>39.3385, :lon=>-120.1729} }
    let(:current) { {coord: {lat: ll[:lat].to_s, lon: ll[:lon].to_s}} }
    let(:forecast) { {"list" => []} }

    before { allow(place).to receive_message_chain(:ow_api, :forecast).and_return(forecast) }

    subject { place.refresh_weather }

    context "when weather data is fresh" do
      let(:updated_at) { DateTime.now.utc }
      it "should return false" do
        expect(subject).to be false
      end
    end

    context "when weather data is stale" do
      let(:updated_at) { DateTime.now.utc - 1.hour }
      it "should return true" do
        expect(place).to receive_message_chain(:ow_api, :current).with(cz).and_return(current)
        expect(subject).to be true
      end

      context "when postal code not found" do
        let(:updated_at) { DateTime.now.utc - 1.hour }
        it "should still return true" do
          allow(place).to receive_message_chain(:ow_api, :current).with(cz).and_raise(RestClient::NotFound)
          expect(place).to receive_message_chain(:ow_api, :current).with(ll).and_return(current)
          expect(subject).to be true
        end
      end
    end
  end

  describe "#condition_icon" do
    let(:place) { build(:place) }
    it "returns open weather icon" do
      expect(place.send(:condition_icon, Place::WK2OW.keys.first)).to eq "01d"
      expect(place.send(:condition_icon, Place::WK2OW.keys.first, false)).to eq "01n"
      expect(place.send(:condition_icon, Place::WK2OW.keys.last)).to eq "09d"
      expect(place.send(:condition_icon, Place::WK2OW.keys.last, false)).to eq "09n"
    end
  end

  describe "#ow_api" do
    let(:place) { build(:place) }
    it "provides open weather api" do
      expect(Rails).to receive_message_chain(:configuration, :open_weather_api)
      place.send(:ow_api)
    end
  end
end
