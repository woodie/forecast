require "geocoder"

class WeatherController < ApplicationController
  protect_from_forgery

  def search
  end

  def result
    query = params[:search][:address].strip
    unless query.present? && query.length >= 5
      flash[:notice] = "Sorry, '#{query}' is not a minimun of 5 characters."
      return redirect_to root_path
    end

    @from_cache = true
    address = Address.find_by(query: query.downcase)
    if address.present?
      @place = address.place
      check_weather(@place)
    else
      coordinates = Geocoder.search(query).first&.coordinates
      unless coordinates.present?
        flash[:notice] = "Sorry, '#{query}' is not a valid address."
        return redirect_to root_path
      end

      geo = Geocoder.search(coordinates).first
      unless geo.present? && geo.postal_code.present?
        flash[:notice] = "Sorry, '#{query}' does not have a postal code."
        return redirect_to root_path
      end

      byzip = Geocoder.search("#{geo.postal_code}, #{geo.country}").first
      @place = Place.find_or_create_by(postal_code: geo.postal_code, country_code: geo.country_code) do |place|
        place.city = geo.city
        place.state = geo.state || geo.data["address"]["district"] || geo.data["address"]["province"]
        place.country = geo.country
        if byzip.present? && byzip.postal_code == geo.postal_code && byzip.country_code == geo.country_code
          place.lat = byzip.latitude
          place.lon = byzip.longitude
        end
      end
      check_weather(@place)
      Address.find_or_create_by(query: query.downcase, place: @place)
    end
  end

  def check_weather(place)
    return if place.updated_at > Time.now - 30.minutes &&
      place.current_weather.present? && place.weather_forecast.present?

    current_weather = ow_api.current(lat: place.lat, lon: place.lon)
    if current_weather.nil?
      flash[:notice] = "Sorry, weather data unavailable for this postal code."
      return redirect_to root_path
    end
    place.update(lat: current_weather[:coord][:lat]) if place.lat != current_weather[:coord][:lat]
    place.update(lon: current_weather[:coord][:lon]) if place.lon != current_weather[:coord][:lon]
    place.update(current_weather: current_weather)

    weather_forecast = ow_api.forecast(lat: place.lat, lon: place.lon)
    place.update(weather_forecast: weather_forecast)
    @from_cache = false
  end

  private

  def ow_api
    @ow_api || @ow_api = Rails.configuration.open_weather_api
  end

  # Only allow a list of trusted parameters through.
  def address_params
    params.expect(:query)
  end
end

# monkey patch open-weather-api-0.0.7/lib/open-weather-api/resources/base.rb
module OpenWeatherAPI
  module Resources
    class Base
      def execute(**hash, &block)
        @parameters = hash
        setup_indifferent_access(@parameters)
        begin
          puts @parameters
          response = RestClient.send :get, base_url, params: build_params(@parameters)
        rescue RestClient::NotFound
          return
        end
        response = send :"handle_response_#{mode}", response
        return block.call(response) if block_given?
        response
      end
    end
  end
end
