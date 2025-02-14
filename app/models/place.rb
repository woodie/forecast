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
      legacy_weather wk_api.weather(lat, lon, data_sets: [:current_weather]).weather
    else
      ow_api.current(lat: lat, lon: lon)
    end
    update(current_weather: weather_data)

    forecast_data = if Feature.active?(:use_wk_api)
      arrange_forecast wk_api.weather(lat, lon, data_sets: [:forecast_hourly, :forecast_daily]).weather
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
    cw = wd.current_weather
    code = cw.condition_code
    {coord: {lon: cw.metadata.longitude, lat: cw.metadata.latitude},
     dt: DateTime.parse(cw.as_of).to_i, weather: [
       {id: WeatherIcon.number(code), main: code,
        icon: WeatherIcon.icon(code, cw.daylight),
        description: code.underscore.humanize.downcase}
     ], main: {
       temp: m2k(cw.temperature), feels_like: m2k(cw.temperature_apparent),
       pressure: cw.pressure, humidity: cw.humidity, visibility: cw.visibility
     }}
  end

  def legacy_forecast(wd, ex)
    code = wd.condition_code
    {dt: DateTime.parse(wd.forecast_start).to_i, weather: [
      {id: WeatherIcon.number(code), main: code,
       icon: WeatherIcon.icon(code, wd.respond_to?(:daylight) ? wd.daylight : false),
       description: code.underscore.humanize.downcase}
    ], main: {temp: m2k(wd.respond_to?(:temperature) ? wd.temperature : ex[:temp]),
              temp_min: m2k(wd.respond_to?(:temperature_min) ? wd.temperature_min : ex[:temp_min]),
              temp_max: m2k(wd.respond_to?(:temperature_max) ? wd.temperature_max : ex[:temp_max])}}
  end

  def arrange_forecast(feed)
    payload = {hourly: [], daily: []}
    if feed.is_a?(Hash) && feed["list"].present?
      payload[:hourly] = feed["list"].first(5)
      payload[:daily] = feed["list"].values_at(7, 15, 24, 31, 39).to_a
    elsif feed.respond_to?(:forecast_hourly) && feed.respond_to?(:forecast_daily)
      fhs = feed.forecast_hourly.hours
      fds = feed.forecast_daily.days
      dtn = DateTime.parse(fds.first.rest_of_day_forecast.forecast_start).to_i
      fhx = next_hour_at(fhs, dtn)
      fdo = [fds.first, fds.first, fds.first, fds.first.daytime_forecast, fds.first.rest_of_day_forecast]
      payload[:hourly] = fhs.values_at(fhx + 2, fhx + 5, fhx + 8, fhx + 11, fhx + 14).map.with_index do |wd, i|
        ex = {temp_min: fdo[i].temperature_min, temp_max: fdo[i].temperature_max}
        legacy_forecast(wd, ex)
      end
      payload[:daily] = fds[1, 5].map.with_index do |wd, i|
        ex = {temp: fhs[i * 24 + 24 + fhx].temperature}
        legacy_forecast(wd, ex)
      end
      wd = fds.first.rest_of_day_forecast
      ex = {temp: fhs[[fhx - 1, 0].max].temperature}
      payload[:rest_of_day] = legacy_forecast(wd, ex)
    end
    payload
  end

  def next_hour_at(feed_hours, dt_now = DateTime.now.to_i)
    feed_hours.each_with_index do |w, i|
      asof = DateTime.parse(w.forecast_start).to_i
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
