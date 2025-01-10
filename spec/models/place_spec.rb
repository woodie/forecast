require "rails_helper"

RSpec.describe Place, type: :model do
  let(:place) { build(:place) }
  let(:wk_obj) do
    {"currentWeather" => {
      "metadata" => {"longitude" => -120.18, "latitude" => 39.33},
      "asOf" => "2024-12-28T11:06:03Z", "temperature" => 1.84,
      "temperatureApparent" => -3.3, "conditionCode" => "Cloudy", "daylight" => false,
      "pressure" => 1013.46, "humidity" => 0.88, "visibility" => 1662.17
    }, "forecastDaily" => {"days" => [
      {"restOfDayForecast" => {"temperatureMin" => 1.32, "temperatureMax" => 6.38}}
    ]}}
  end

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
    let(:coords) { {lat: 39.3385, lon: -120.1729} }
    let(:current) { {coord: {lat: coords[:lat].to_s, lon: coords[:lon].to_s}} }
    let(:forecast) { {"list" => []} }

    subject { place.refresh_weather }

    context "when weather data is fresh" do
      let(:updated_at) { DateTime.now.utc }
      it "should return false" do
        expect(subject).to be false
      end
    end

    context "when weather data is stale" do
      let(:updated_at) { DateTime.now.utc - 1.hour }

      context "when @use_wk_api is false" do
        before do
          place.use_wk_api = false
          allow(place).to receive_message_chain(:ow_api, :forecast).and_return(forecast)
        end
        it "should return true" do
          expect(place).to receive_message_chain(:ow_api, :current).with(coords).and_return(current)
          expect(subject).to be true
        end
      end

      context "when @use_wk_api is true" do
        before do
          place.use_wk_api = true
          allow(place).to receive_message_chain(:wk_api, :forecast).and_return(forecast)
        end
        it "should return true" do
          expect(place).to receive_message_chain(:wk_api, :current).with(coords).and_return(wk_obj)
          expect(subject).to be true
        end
      end
    end
  end

  describe "#icon" do
    it "returns Open Weather icon" do
      expect(place.icon("Clear")).to eq "01d"
      expect(place.icon("Clear", false)).to eq "01n"
      expect(place.icon("Snow")).to eq "13d"
      expect(place.icon("Snow", false)).to eq "13n"
      expect(place.icon("Dust")).to eq "50d"
      expect(place.icon("Dust", false)).to eq "50n"
    end
  end

  describe "#legacy_weather" do
    let(:payload) do
      {coord: {lat: 39.33, lon: -120.18}, dt: 1735383963,
       main: {feels_like: 269.85, humidity: 0.88, pressure: 1013.46,
              temp: 274.99, temp_max: 279.53, temp_min: 274.47, visibility: 1662.17},
       weather: [{id: 801, description: "cloudy", icon: "02n", main: "Cloudy"}]}
    end

    it "returns Open Weather payload" do
      expect(place.send(:legacy_weather, wk_obj)).to match payload
    end
  end

  describe "#legacy_forecast" do
    let(:temp) { 1.84 }
    let(:min) { 1.32 }
    let(:max) { 6.38 }
    let(:feed) do
      {"forecastStart" => "2024-12-28T11:06:03Z", "conditionCode" => "Cloudy",
       "temperature" => temp, "temperatureMin" => min, "temperatureMax" => max}
    end
    let(:comp) do
      {dt: 1735383963, main: {temp: 274.99, temp_max: 279.53, temp_min: 274.47},
       weather: [{id: 801, description: "cloudy", icon: "02n", main: "Cloudy"}]}
    end

    context "with hourly feed missing min/max" do
      let(:max) { nil }
      let(:min) { nil }
      let(:ex) { {temp_max: 6.38, temp_min: 1.32} }

      it "returns composite payload" do
        expect(place.send(:legacy_forecast, feed, ex)).to match(comp)
      end
    end

    context "with daily feed missing temp" do
      let(:temp) { nil }
      let(:ex) { {temp: 1.84} }

      it "returns composite payload" do
        expect(place.send(:legacy_forecast, feed, ex)).to match(comp)
      end
    end
  end

  describe "#arrange_forecast" do
    context "with OW payload" do
      let(:data) { {weather: :data} }
      let(:tidy) { {hourly: Array.new(5) { data }, daily: Array.new(5) { data }} }
      let(:feed) { {"list" => Array.new(40) { data }} }

      it "sets hourly and daily data" do
        expect(place.send(:arrange_forecast, feed)).to match(tidy)
      end
    end

    context "with WK payload" do
      let(:feed) { JSON.parse File.read("test/fixtures/forecast.json") }

      it "sets hourly and daily data" do
        resp = place.send(:arrange_forecast, feed)
        expect(resp[:hourly].size).to be 5
        expect(resp[:daily].size).to be 5
      end
    end
  end

  describe "#next_hour_at" do
    let(:before) { DateTime.now - 5.hours }
    let(:feed) { 10.times.map { |i| {"forecastStart" => (before + i.hours).to_s} } }

    it "returns index to next hours data" do
      expect(place.send(:next_hour_at, feed)).to be 6
    end

    context "when all entries are in the past" do
      let(:before) { DateTime.now - 12.hours }

      it "returns -1 to indicate bad data" do
        expect(place.send(:next_hour_at, feed)).to be(-1)
      end
    end
  end

  describe "#m2k" do
    it "converts metric to kelvin" do
      expect(place.send(:m2k, 0.0)).to be 273.15
    end
  end

  describe "#ow_api" do
    it "provides Open Weather api" do
      expect(Rails).to receive_message_chain(:configuration, :open_weather_api)
      place.send(:ow_api)
    end
  end

  describe "#wk_api" do
    it "provides Apple WeatherKit api" do
      expect(Tenkit::Client).to receive(:new)
      place.send(:wk_api)
    end
  end
end
