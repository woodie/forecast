require "rails_helper"

RSpec.describe 'Tenkin::Client' do
  let(:lat) { 39.3385 }
  let(:lon) { -120.1729 } 
  let(:coords) { {lat: lat, lon: lon} }

  subject { Tenkit::Client.new  }

  describe "#current" do
    let(:path) { "/weather/en/#{lat}/#{lon}?dataSets=currentWeather,forecastDaily" }
    it "passes currentWeather & forecastDaily" do
      expect(subject).to receive(:get).with(path)
      subject.current(coords)
    end 
  end 

  describe "#forecast" do
    let(:path) { "/weather/en/#{lat}/#{lon}?dataSets=forecastHourly,forecastDaily" }
    it "passes forecastHourly & forecastDaily" do
      expect(subject).to receive(:get).with(path)
      subject.forecast(coords)
    end 
  end 
end
