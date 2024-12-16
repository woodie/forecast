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
    let(:lat) { 40.1234 }
    let(:lon) { -120.1234 }
    let(:cz) { {country_code: "us", zipcode: "96161"} }
    let(:ll) { {lat: lat, lon: lon} }
    let(:weather_data) { {coord: {lat: lat.to_s, lon: lon.to_s}} }
    let(:forecast_data) { {"list" => []} }
    let(:place) {
      described_class.new(
        city: "Truckee",
        state: "California",
        country: "United States",
        country_code: "us",
        postal_code: "96161",
        lat: lat,
        lon: lon,
        current_weather: weather_data,
        weather_forecast: forecast_data,
        updated_at: updated_at
      )
    }

    before { allow(place).to receive_message_chain(:ow_api, :forecast).and_return(forecast_data) }

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
        expect(place).to receive_message_chain(:ow_api, :current).with(cz).and_return(weather_data)
        expect(subject).to be true
      end

      context "when postal code not found" do
        let(:updated_at) { DateTime.now.utc - 1.hour }
        it "should still return true" do
          allow(place).to receive_message_chain(:ow_api, :current).with(cz).and_raise(RestClient::NotFound)
          expect(place).to receive_message_chain(:ow_api, :current).with(ll).and_return(weather_data)
          expect(subject).to be true
        end
      end
    end
  end
end
