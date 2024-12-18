require "rails_helper"

RSpec.describe "Weather", type: :request do
  describe "GET /" do
    it "renders search page" do
      get root_url
      expect(response).to be_successful
    end
  end

  describe "POST /" do
    context "with too few characters of input" do
      it "redirects to search page with flash message" do
        post root_url, params: {"search[address]": "123"}
        expect(flash[:notice]).to end_with "not a minimun of 5 characters."
        expect(response).to redirect_to(root_url)
      end
    end

    context "with geocoder processing addresses" do
      let(:postal_code) { "96161" }
      let(:payload) do
        {city: "Truckee", state: "California", postal_code: postal_code,
         country: "United states", country_code: "us",
         latitude: "40.1234", longitude: "-120.1234",
         coordinates: ["40.1234", "-120.1234"]}
      end
      let(:result) { [double("GeocoderResult", payload)] }

      before(:each) do
        allow(Geocoder).to receive(:search).and_return(result)
      end

      context "with unknown/invalid address" do
        let(:result) { [] }
        it "redirects to search page with flash message" do
          post root_url, params: {"search[address]": "Olympus Mons, Mars"}
          expect(flash[:notice]).to end_with "not a valid address."
          expect(response).to redirect_to(root_url)
        end
      end

      context "with no postal code at address" do
        let(:postal_code) { nil }
        it "redirects to search page with flash message" do
          post root_url, params: {"search[address]": "Antarctica"}
          expect(flash[:notice]).to end_with "does not have a postal code."
          expect(response).to redirect_to(root_url)
        end
      end

      context "with valid postal address" do
        context "with bad openweather API key" do
          before { allow_any_instance_of(Place).to receive_message_chain(:ow_api, :current).and_raise(RestClient::Unauthorized) }
          it "redirects to search page with flash message" do
            post root_url, params: {"search[address]": "Cupertino, CA"}
            expect(flash[:notice]).to end_with "weather service cannot process request."
            expect(response).to redirect_to(root_url)
          end
        end

        context "with current weather and forcast data" do
          let(:lat) { 40.1234 }
          let(:lon) { -120.1234 }
          let(:weather_data) do
            {coord: {lat: lat.to_s, lon: lon.to_s},
             weather: [{icon: '12c'}], dt: 1732656764, timezone: -28800,
             main: {temp: 50, feels_like: 49, temp_min: 48, temp_max: 51}}
          end
          let(:forecast_data) { {"list" => Array.new(40) { weather_data }} }
          let(:place) {
            Place.new(
              city: "Truckee",
              state: "California",
              country: "United States",
              country_code: "us",
              postal_code: "96161",
              lat: lat,
              lon: lon,
              current_weather: weather_data,
              weather_forecast: forecast_data,
              updated_at: DateTime.now.utc
            )
          }
          before { allow(Place).to receive(:geo_create).and_return(place) }

          it "renders the result page" do
            post root_url, params: {"search[address]": "Cupertino, CA"}
            expect(flash[:notice]).to be_nil
            expect(response).not_to redirect_to(root_url)
          end
        end
      end
    end
  end
end
