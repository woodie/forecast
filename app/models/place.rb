class Place < ApplicationRecord
  has_many :addresses

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

    weather_data = if Feature.active?(:use_wk_api)
      legacy_weather wk_api.weather(lat, lon, data_sets: [:current_weather]).raw
    else
      ow_api.current(lat: lat, lon: lon)
    end
    update(current_weather: weather_data)

    forecast_data = if Feature.active?(:use_wk_api)
      arrange_forecast wk_api.weather(lat, lon, data_sets: [:forecast_hourly, :forecast_daily]).raw
    else
      arrange_forecast ow_api.forecast(lat: lat, lon: lon)
    end
    update(weather_forecast: forecast_data)
    true
  end

  def composite_main
    return current_weather["main"] unless weather_forecast.has_key?("rest_of_day")
    weather_forecast["rest_of_day"]["main"].merge current_weather["main"]
  end

  private

  def legacy_weather(wd)
    cw = wd["currentWeather"]
    code = cw["conditionCode"]
    {coord: {lon: cw["metadata"]["longitude"], lat: cw["metadata"]["latitude"]},
     dt: DateTime.parse(cw["asOf"]).to_i, weather: [
       {id: WeatherIcon.number(code), main: code,
        icon: WeatherIcon.icon(code, cw["daylight"]),
        description: code.underscore.humanize.downcase}
     ], main: {
       temp: m2k(cw["temperature"]), feels_like: m2k(cw["temperatureApparent"]),
       pressure: cw["pressure"], humidity: cw["humidity"], visibility: cw["visibility"]
     }}
  end

  def legacy_forecast(wd, ex)
    code = wd["conditionCode"]
    {dt: DateTime.parse(wd["forecastStart"]).to_i, weather: [
      {id: WeatherIcon.number(code), main: code,
       icon: WeatherIcon.icon(code, wd["daylight"]),
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
      dtn = DateTime.parse(fds.first["restOfDayForecast"]["forecastStart"]).to_i
      fhx = next_hour_at(fhs, dtn)
      fdo = [fds.first, fds.first, fds.first, fds.first["daytimeForecast"], fds.first["restOfDayForecast"]]
      payload[:hourly] = fhs.values_at(fhx + 2, fhx + 5, fhx + 8, fhx + 11, fhx + 14).map.with_index do |wd, i|
        ex = {temp_min: fdo[i]["temperatureMin"], temp_max: fdo[i]["temperatureMax"]}
        legacy_forecast(wd, ex)
      end
      payload[:daily] = fds[1, 5].map.with_index do |wd, i|
        ex = {temp: fhs[i * 24 + 24 + fhx]["temperature"]}
        legacy_forecast(wd, ex)
      end
      wd = fds.first["restOfDayForecast"]
      ex = {temp: fhs[[fhx - 1, 0].max]["temperature"]}
      payload[:rest_of_day] = legacy_forecast(wd, ex)
    end
    payload
  end

  def next_hour_at(feed_hours, dt_now = DateTime.now.to_i)
    feed_hours.each_with_index do |w, i|
      asof = DateTime.parse(w["forecastStart"]).to_i
      return i if asof > dt_now
    end
    -1
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
