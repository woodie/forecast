class Place < ApplicationRecord

  def self.geo_create(geo)
    find_or_create_by(postal_code: geo.postal_code, country_code: geo.country_code) do |place|
      place.city = geo.city
      place.state = geo.state || geo.data["address"]["district"] || geo.data["address"]["province"]
      place.country = geo.country
      place.lat = geo.latitude
      place.lon = geo.longitude
    end
  end

  def refresh_weather
    return false if updated_at > Time.now - 30.minutes &&
      current_weather.present? && weather_forecast.present?

    begin
      weather_data = ow_api.current(zipcode: postal_code, country_code: country_code)
    rescue RestClient::NotFound
      # Fall back to lat/lon when postal code is unknown
      weather_data = ow_api.current(lat: lat, lon: lon)
    end
    update(lat: weather_data[:coord][:lat]) if lat != weather_data[:coord][:lat]
    update(lon: weather_data[:coord][:lon]) if lon != weather_data[:coord][:lon]
    update(current_weather: weather_data)

    forecast_data = ow_api.forecast(lat: lat, lon: lon)
    update(weather_forecast: forecast_data)
    true
  end

  private

  def ow_api
    @ow_api || @ow_api = Rails.configuration.open_weather_api
  end
end
