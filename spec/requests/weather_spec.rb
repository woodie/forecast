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

    context "with unknown/invalid address" do
      it "redirects to search page with flash message" do
        post root_url, params: {"search[address]": "Olympus Mons, Mars"}
        expect(flash[:notice]).to end_with "not a valid address."
        expect(response).to redirect_to(root_url)
      end
    end

    context "with no postal code at address" do
      it "redirects to search page with flash message" do
        post root_url, params: {"search[address]": "Antarctica"}
        expect(flash[:notice]).to end_with "does not have a postal code."
        expect(response).to redirect_to(root_url)
      end
    end
    context "with valid postal address" do
      context "with bad openweather API key" do
        before { Rails.configuration.open_weather_api.api_key = "invalid" }
        it "redirects to search page with flash message" do
          post root_url, params: {"search[address]": "Cupertino, CA"}
          expect(flash[:notice]).to end_with "weather service cannot process request."
          expect(response).to redirect_to(root_url)
        end
      end

      context "with valid configuration" do
        it "redirects to the result page" do
          post root_url, params: {"search[address]": "Cupertino, CA"}
          expect(response).to redirect_to(result_url)
        end
      end
    end
  end
end

# TODO: Mock all API calls and disable the key to test env.
