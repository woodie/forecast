class Place < ApplicationRecord
  WK2OW = {Clear: 1, Cloudy: 3, Dust: 50, Fog: 50, Haze: 50, MostlyClear: 1,
           MostlyCloudy: 3, PartlyCloudy: 3, ScatteredThunderstorms: 11, Smoke: 50,
           Breezy: 50, Windy: 50, Drizzle: 10, HeavyRain: 10, Rain: 10, Showers: 10,
           Flurries: 13, HeavySnow: 13, MixedRainAndSleet: 9, MixedRainAndSnow: 9,
           MixedRainfall: 10, MixedSnowAndSleet: 9, ScatteredShowers: 9,
           ScatteredSnowShowers: 9, Sleet: 13, Snow: 13, SnowShowers: 13,
           Blizzard: 13, BlowingSnow: 13, FreezingDrizzle: 10, FreezingRain: 10,
           Frigid: 13, Hail: 10, Hot: 1, Hurricane: 50, IsolatedThunderstorms: 11,
           SevereThunderstorm: 11, Thunderstorm: 11, Tornado: 50, TropicalStorm: 9}

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

  def convert_payload # TODO
    {weather: [{icon: '03d', description: 'Cloudy'}],
     main: {temp: 274.99, feels_like: 269.85,
            temp_min: 274.47, temp_max: 279.53},
     dt: 1735383963, timezone: -28800}
  end

  def condition_icon(condition, daylight = true)
    num = WK2OW[condition.to_sym].to_s # TODO: handle zero
    "#{num.rjust(2, "0")}#{daylight ? "d" : "n"}"
  end

  def ow_api
    @ow_api || @ow_api = Rails.configuration.open_weather_api
  end
end
