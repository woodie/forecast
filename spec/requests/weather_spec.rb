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
        context "with current weather and forcast data" do
          before { create(:address) }
          it "renders the result page" do
            post root_url, params: {"search[address]": "Truckee, CA"}
            expect(flash[:notice]).to be_nil
            expect(response).not_to redirect_to(root_url)
          end
        end
      end
    end
  end
end
