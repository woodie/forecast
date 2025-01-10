class Place < ApplicationRecord
  attr_writer :use_wk_api

  NEUTRAL = [210, 310, 601, 602] + [771, 901, 905] # forced + no-d/n, see: /owm-codes.html & /icons
  ICON_ID = {Clear: 800, Cloudy: 801, Dust: 731, Fog: 741, Haze: 721, MostlyClear: 800,
             MostlyCloudy: 804, PartlyCloudy: 801, ScatteredThunderstorms: 200, Smoke: 711,
             Breezy: 771, Windy: 957, Drizzle: 500, HeavyRain: 310, Rain: 520, Showers: 520,
             Flurries: 600, HeavySnow: 601, MixedRainAndSleet: 310, MixedRainAndSnow: 611,
             MixedRainfall: 310, MixedSnowAndSleet: 611, ScatteredShowers: 520,
             ScatteredSnowShowers: 511, Sleet: 611, Snow: 600, SnowShowers: 601,
             Blizzard: 601, BlowingSnow: 601, FreezingDrizzle: 602, FreezingRain: 602,
             Frigid: 903, Hail: 906, Hot: 904, Hurricane: 902, IsolatedThunderstorms: 200,
             SevereThunderstorm: 210, Thunderstorm: 200, Tornado: 781, TropicalStorm: 200}
  # https://openweathermap.org/weather-conditions
  OW_TEXT = {ClearSky: 1, FewClouds: 2, ScatteredClouds: 3, BrokenClouds: 4,
             ShowerRain: 9, Rain: 10, Thunderstorm: 11, Snow: 13, Mist: 50}
  OW_ICON = {200 => 11, 210 => 11, 310 => 9, 500 => 10, 511 => 13, 520 => 9,
             600 => 13, 601 => 13, 602 => 10, 611 => 9, 800 => 1, 801 => 2,
             804 => 3, 903 => 13, 904 => 1, 906 => 10, 957 => 50} # default 50

  def initialize(params)
    super
    @use_wk_api = true # should use rollout gem
  end

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

    weather_data = if @use_wk_api
      legacy_weather wk_api.current(lat: lat, lon: lon)
    else
      ow_api.current(lat: lat, lon: lon)
    end
    update(current_weather: weather_data)

    forecast_data = if @use_wk_api
      arrange_forecast wk_api.forecast(lat: lat, lon: lon)
    else
      arrange_forecast ow_api.forecast(lat: lat, lon: lon)
    end
    update(weather_forecast: forecast_data)
    true
  end

  def icon(code, daylight = true)
    num = OW_ICON[number(code)] || 50
    "#{num.to_s.rjust(2, "0")}#{daylight ? "d" : "n"}"
  end

  private

  def legacy_weather(wd)
    cw = wd["currentWeather"]
    df = wd["forecastDaily"]["days"].first["restOfDayForecast"]
    code = cw["conditionCode"]
    {coord: {lon: cw["metadata"]["longitude"], lat: cw["metadata"]["latitude"]},
     dt: DateTime.parse(cw["asOf"]).to_i, weather: [
       {id: number(code), main: code, icon: icon(code, cw["daylight"]),
        description: code.underscore.humanize.downcase}
     ], main: {
       temp: m2k(cw["temperature"]), feels_like: m2k(cw["temperatureApparent"]),
       temp_min: m2k(df["temperatureMin"]), temp_max: m2k(df["temperatureMax"]),
       pressure: cw["pressure"], humidity: cw["humidity"], visibility: cw["visibility"]
     }}
  end

  def legacy_forecast(wd, ex)
    code = wd["conditionCode"]
    {dt: DateTime.parse(wd["forecastStart"]).to_i, weather: [
      {id: number(code), main: code, icon: icon(code, wd["daylight"]),
       description: code.underscore.humanize.downcase}
    ], main: {temp: m2k(wd["temperature"] || ex[:temp]),
              temp_min: m2k(wd["temperatureMin"] || ex[:temp_min]),
              temp_max: m2k(wd["temperatureMax"] || ex[:temp_max])}}
  end

  def arrange_forecast(feed)
    payload = {hourly: [], daily: []}
    if feed["list"].present?
      payload[:hourly] = feed["list"].first(5)
      payload[:daily] = feed["list"].values_at(7, 15, 24, 31, 39).to_a
    elsif feed["forecastHourly"].present? && feed["forecastDaily"].present?
      fhs = feed["forecastHourly"]["hours"]
      fds = feed["forecastDaily"]["days"]
      fhx = next_hour_at(fhs)
      fdo = [fds.first, fds.first, fds.first, fds.first["daytimeForecast"], fds.first["restOfDayForecast"]]
      payload[:hourly] = fhs.values_at(fhx + 2, fhx + 5, fhx + 8, fhx + 11, fhx + 14).map.with_index do |wd, i|
        ex = {temp_min: fdo[i]["temperatureMin"], temp_max: fdo[i]["temperatureMax"]}
        legacy_forecast(wd, ex)
      end
      payload[:daily] = fds[1, 5].map.with_index do |wd, i|
        ex = {temp: fhs[i * 24 + 24 + fhx]["temperature"]}
        legacy_forecast(wd, ex)
      end
    end
    payload
  end

  def next_hour_at(feed_hours)
    now = Time.now.to_i
    feed_hours.each_with_index do |w, i|
      asof = DateTime.parse(w["forecastStart"]).to_i
      return i if asof > now
    end
    -1
  end

  def number(code)
    ICON_ID[code.to_sym]
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
