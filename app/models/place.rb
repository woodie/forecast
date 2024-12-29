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
      place.timezone = TimezoneFinder.create.timezone_at(lat: geo.latitude.to_f, lng: geo.longitude.to_f)
    end
  end

  def refresh_weather
    return false if updated_at > Time.now - 30.minutes &&
      current_weather.present? && weather_forecast.present?

    weather_data = ow_api.current(lat: lat, lon: lon)
    # weather_data = legacy_payload wk_api.weather(lat, lon, [:current_weather, :forecast_daily]).raw
    update(current_weather: weather_data)

    forecast_data = ow_api.forecast(lat: lat, lon: lon)
    update(weather_forecast: forecast_data)
    true
  end

  private

  def legacy_payload(raw)
    cw = raw["currentWeather"]
    df = raw["forecastDaily"]["days"].first["restOfDayForecast"]
    code = cw["conditionCode"]
    {coord: {lon: cw["metadata"]["longitude"], lat: cw["metadata"]["latitude"]},
     dt: DateTime.parse(cw["asOf"]).to_i, weather: [
       {main: code, description: code.downcase, icon: icon(code, cw["daylight"])}
     ], main: {
       temp: m2k(cw["temperature"]), feels_like: m2k(cw["temperatureApparent"]),
       temp_min: m2k(df["temperatureMin"]), temp_max: m2k(df["temperatureMax"]),
       pressure: cw["pressure"], humidity: cw["humidity"], visibility: cw["visibility"]
     }}
  end

  def icon(condition, daylight = true)
    num = WK2OW[condition.to_sym].to_s
    "#{num.rjust(2, "0")}#{daylight ? "d" : "n"}"
  end

  def m2k(m)
    (m + 273.15).round(2)
  end

  def ow_api
    @ow_api || @ow_api = Rails.configuration.open_weather_api
  end

  def wk_api
    @wk_api || @wk_api = Tenkit::Client.new
  end
end
