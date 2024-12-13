require "rails_helper"

RSpec.describe WeatherController, type: :routing do
  describe "routing" do
    it "routes to #search" do
      expect(get: "/").to route_to("weather#search")
    end

    it "routes to #result" do
      expect(post: "/").to route_to("weather#result")
    end
  end
end
