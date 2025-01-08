require "rails_helper"

RSpec.describe "Tenkin::Client" do
  let(:lat) { 10.02 }
  let(:lon) { -84.2 }
  let(:coords) { {lat: lat, lon: lon} }

  subject { Tenkit::Client.new }

  describe "#current" do
    let(:path) { "/weather/en/#{lat}/#{lon}?dataSets=currentWeather,forecastDaily" }
    let(:feed) { JSON.parse File.read("test/fixtures/current.json") }
    it "contains expected keys" do
      expect(subject).to receive(:get).with(path).and_return(feed)
      resp = subject.current(coords)
      expect(resp["currentWeather"]).to be_present
      expect(resp["forecastDaily"]).to be_present
    end
  end

  describe "#forecast" do
    let(:path) { "/weather/en/#{lat}/#{lon}?dataSets=forecastHourly,forecastDaily" }
    let(:feed) { JSON.parse File.read("test/fixtures/forecast.json") }
    it "contains expected keys" do
      expect(subject).to receive(:get).with(path).and_return(feed)
      resp = subject.forecast(coords)
      expect(resp["forecastHourly"]).to be_present
      expect(resp["forecastDaily"]).to be_present
    end
  end
end
