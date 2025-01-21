# Apple WeatherKit API

We will retrieve current temperature for the given address,
as well as high/low and extended forecast.
We will cache the forecast by zip (postal) code.

### TenKit library

The TenKit library handles configuration and authentication but is incomplete.
We decided to just patch in [our own methods](https://github.com/woodie/forecast/blob/main/config/initializers/apple-weather-api.rb#L10-L16) to address issues with the current TenKit API:
- The `client.weather` method does not accept intended params.
- The mapping from camel-case to snake-case is incomplete

### Timezone for a location

We show local weather information for any location,
but WeatherKit does not provide the TZ offset (as does OpenWeather).
We can use `timezone_finder` to get a TZ for any lat/lon without an API call.
If we decide to use an offset, we can get that from the `timezone` gem.

```rb
tf = TimezoneFinder.create

lat, lon = [39.3385, -120.1729] # Truckee
tf.timezone_at(lat: lat, lng: lon) => "America/Los_Angeles"
Timezone['America/Los_Angeles'].utc_offset => -28800
lat, lon = [35.021, 135.7556] # Kyoto
tf.timezone_at(lat: lat, lng: lon) => "Asia/Tokyo"
Timezone['Asia/Tokyo'].utc_offset => 32400

dt = DateTime.parse("2024-12-28T03:20:45Z").to_i
Time.at(dt).localtime(-28800).strftime("%-l:%M%P") => "7:20pm"
Time.at(dt).in_time_zone('America/Los_Angeles').strftime("%-l:%M%P") => "7:20pm"
```
Now that we're doing this extra work to get the timezone,
we can use that instead of offset which will be more accurate
when displaying hourly forecast while coming in and out of DST.

### Weather icons

We can use some WeatherKit compatible icons named with
[condition code](https://github.com/hrbrmstr/weatherkit/blob/batman/R/enumerations.R)
and provide a mapping from [open weather icon](https://openweathermap.org/weather-conditions) codes.
Or create our own mapping from WeatherKit to a library like
[this](https://erikflowers.github.io/weather-icons/api-list.html).

![icons](https://camo.githubusercontent.com/685bc5c7307ae21265819ba60ad1bf5cee72f74534696c926414db7e6a62e3b6/687474703a2f2f692e696d6775722e636f6d2f586d5a573271332e706e67)

We created a couple pages to help map WK weather conditions:
- /owm-codes.html - displays WI OWM codes available from WI CSS
- /icons - displays how WI CSS and OW PNG map to WK weather conditions

### Sample data

```rb
Tenkit.configure do |c|
  c.team_id = ENV["APPLE_DEVELOPER_TEAM_ID"]
  c.service_id = ENV["APPLE_DEVELOPER_SERVICE_ID"]
  c.key_id = ENV["APPLE_DEVELOPER_KEY_ID"]
  c.key =  ENV["APPLE_DEVELOPER_PRIVATE_KEY"]
end

# tenkit-0.0.5/lib/tenkit/client.rb
module Tenkit
  class Client
    def weather(lat, lon, data_sets = [:current_weather], language = 'en') # patch required
      path_root = "/weather/#{language}/#{lat}/#{lon}?dataSets="
      path = path_root + data_sets.map { |ds| DATA_SETS[ds] }.compact.join(',')
      response = get(path)
      WeatherResponse.new(response)
    end
  end
end
# tenkit-0.0.5/lib/tenkit/day_weather_conditions.rb initializer also broken

client = Tenkit::Client.new
lat = 39.32812335
lon = -120.18355330161927
sets = [:current_weather, :forecast_daily, :forecast_hourly]

data = client.weather(lat, lon, sets)

# with patched gem
data.weather.current_weather.metadata.latitude => 39.33
data.weather.current_weather.metadata.longitude => -120.18
data.weather.current_weather.as_of => "2024-12-28T11:06:03Z"
DateTime.parse(data.weather.current_weather.as_of).to_i => 1735383963
data.weather.current_weather.temperature => 1.84
data.weather.current_weather.temperature_apparent => -3.3
data.weather.current_weather.condition_code => "Cloudy"
data.weather.current_weather.daylight => false
data.weather.forecast_daily.days.size => 9
data.weather.forecast_daily.days.first.forecast_start => "2024-12-28T08:00:00Z"
data.weather.forecast_daily.days.first.temperature_min => 1.32
data.weather.forecast_daily.days.first.temperature_max => 6.38

data.raw['forecastDaily']['days'].first['restOfDayForecast']['forecastStart'] => "2024-12-28T11:06:03Z"
data.raw['forecastDaily']['days'].first['restOfDayForecast']['temperatureMin'] => 1.84
data.raw['forecastDaily']['days'].first['restOfDayForecast']['temperatureMax'] => 6.38
data.raw['forecastDaily']['days'].first['restOfDayForecast']['conditionCode'] => "Drizzle"

data.weather.forecast_hourly.hours.size => 243
data.weather.forecast_hourly.hours.first["forecastStart"] => "2024-12-27T07:00:00Z"
data.weather.forecast_hourly.hours.first['temperature'] => -0.63
data.weather.forecast_hourly.hours.last["forecastStart"] => "2025-01-06T09:00:00Z"
data.weather.forecast_hourly.hours.last['temperature'] => -4.14

# With bogus credentials
client.weather(lat, lon).as_json
{"raw"=>{"reason"=>"NOT_ENABLED"},
 "weather"=>
  {"current_weather"=>{}, "forecast_daily"=>{}, "forecast_hourly"=>{},
   "forecast_next_hour"=>{}, "weather_alerts"=>{}}}

# With proper credentials
client.weather(lat, lon, sets).as_json
 =>
{"raw"=>
  {"currentWeather"=>
    {"name"=>"CurrentWeather",
     "metadata"=>
      {"attributionURL"=>"https://developer.apple.com/weatherkit/data-source-attribution/",
       "expireTime"=>"2024-12-27T07:49:39Z",
       "latitude"=>39.33,
       "longitude"=>-120.18,
       "readTime"=>"2024-12-27T07:44:39Z",
       "reportedTime"=>"2024-12-27T07:44:39Z",
       "units"=>"m",
       "version"=>1,
       "sourceType"=>"modeled"},
     "asOf"=>"2024-12-27T07:44:39Z",
     "cloudCover"=>1.0,
     "cloudCoverLowAltPct"=>0.74,
     "cloudCoverMidAltPct"=>0.6,
     "cloudCoverHighAltPct"=>0.98,
     "conditionCode"=>"Snow",
     "daylight"=>false,
     "humidity"=>0.88,
     "precipitationIntensity"=>0.95,
     "pressure"=>1013.46,
     "pressureTrend"=>"falling",
     "temperature"=>-0.89,
     "temperatureApparent"=>-7.4,
     "temperatureDewPoint"=>-2.63,
     "uvIndex"=>0,
     "visibility"=>1662.17,
     "windDirection"=>204,
     "windGust"=>50.14,
     "windSpeed"=>19.62},
   "forecastDaily"=>
    {"name"=>"DailyForecast",
     "metadata"=>
      {"attributionURL"=>"https://developer.apple.com/weatherkit/data-source-attribution/",
       "expireTime"=>"2024-12-27T08:33:01Z",
       "latitude"=>39.33,
       "longitude"=>-120.18,
       "readTime"=>"2024-12-27T07:44:39Z",
       "reportedTime"=>"2024-12-27T06:00:37Z",
       "units"=>"m",
       "version"=>1,
       "sourceType"=>"modeled"},
     "days"=>
      [{"forecastStart"=>"2024-12-26T08:00:00Z",
        "forecastEnd"=>"2024-12-27T08:00:00Z",
        "conditionCode"=>"Snow",
        "maxUvIndex"=>2,
        "moonPhase"=>"waningCrescent",
        "moonrise"=>"2024-12-26T11:25:41Z",
        "moonset"=>"2024-12-26T21:24:16Z",
        "precipitationAmount"=>4.38,
        "precipitationChance"=>1.0,
        "precipitationType"=>"snow",
        "snowfallAmount"=>33.31,
        "solarMidnight"=>"2024-12-26T08:01:27Z",
        "solarNoon"=>"2024-12-26T20:01:44Z",
        "sunrise"=>"2024-12-26T15:19:25Z",
        "sunriseCivil"=>"2024-12-26T14:49:16Z",
        "sunriseCivil"=>"2024-12-26T14:49:16Z",
        "sunriseNautical"=>"2024-12-26T14:15:33Z",
        "sunriseAstronomical"=>"2024-12-26T13:42:55Z",
        "sunset"=>"2024-12-27T00:44:18Z",
        "sunsetCivil"=>"2024-12-27T01:14:22Z",
        "sunsetNautical"=>"2024-12-27T01:48:04Z",
        "sunsetAstronomical"=>"2024-12-27T02:20:43Z",
        "temperatureMax"=>3.13,
        "temperatureMin"=>-0.94,
        "windGustSpeedMax"=>52.32,
        "windSpeedAvg"=>11.72,
        "windSpeedMax"=>20.27,
        "daytimeForecast"=>
         {"forecastStart"=>"2024-12-26T15:00:00Z",
          "forecastEnd"=>"2024-12-27T03:00:00Z",
          "cloudCover"=>0.98,
          "conditionCode"=>"Cloudy",
          "humidity"=>0.87,
          "precipitationAmount"=>1.8,
          "precipitationChance"=>0.43,
          "precipitationType"=>"rain",
          "snowfallAmount"=>6.81,
          "temperatureMax"=>3.13,
          "temperatureMin"=>0.25,
          "windDirection"=>215,
          "windGustSpeedMax"=>42.86,
          "windSpeed"=>11.4,
          "windSpeedMax"=>15.52},
        "overnightForecast"=>
         {"forecastStart"=>"2024-12-27T03:00:00Z", ... },
         {"forecastStart"=>"2024-12-27T07:44:39Z", ... },
       {"forecastStart"=>"2024-12-27T08:00:00Z", ... },
       {"forecastStart"=>"2024-12-28T08:00:00Z", ... },
       ...
   "forecastHourly"=>
    {"name"=>"HourlyForecast",
     "metadata"=>
      {"attributionURL"=>"https://developer.apple.com/weatherkit/data-source-attribution/",
       "expireTime"=>"2024-12-27T08:33:01Z",
       "latitude"=>39.33,
       "longitude"=>-120.18,
       "readTime"=>"2024-12-27T07:44:39Z",
       "reportedTime"=>"2024-12-27T06:00:37Z",
       "units"=>"m",
       "version"=>1,
       "sourceType"=>"modeled"},
     "hours"=>
      [{"forecastStart"=>"2024-12-26T07:00:00Z",
        "cloudCover"=>0.83,
        "conditionCode"=>"MostlyCloudy",
        "daylight"=>false,
        "humidity"=>0.8,
        "precipitationAmount"=>0.0,
        "precipitationIntensity"=>0.0,
        "precipitationChance"=>0.0,
        "precipitationType"=>"clear",
        "pressure"=>1020.97,
        "pressureTrend"=>"falling",
        "snowfallIntensity"=>0.07,
        "snowfallAmount"=>0.07,
        "temperature"=>0.54,
        "temperatureApparent"=>-0.51,
        "temperatureDewPoint"=>-2.52,
        "uvIndex"=>0,
        "visibility"=>28304.39,
        "windDirection"=>199,
        "windGust"=>18.85,
        "windSpeed"=>7.3},
       {"forecastStart"=>"2024-12-26T08:00:00Z", ...},
       {"forecastStart"=>"2024-12-26T09:00:00Z", ...},
       ...
 "weather"=>
  {"current_weather"=>
    {"as_of"=>"2024-12-27T07:44:39Z",
     "cloud_cover"=>1.0,
     "condition_code"=>"Snow",
     "daylight"=>false,
     "humidity"=>0.88,
     "metadata"=>
      {"attribution_url"=>"https://developer.apple.com/weatherkit/data-source-attribution/",
       "expire_time"=>"2024-12-27T07:49:39Z",
       "latitude"=>39.33,
       "longitude"=>-120.18,
       "read_time"=>"2024-12-27T07:44:39Z",
       "reported_time"=>"2024-12-27T07:44:39Z",
       "units"=>"m",
       "version"=>1},
     "precipitation_intensity"=>0.95,
     "pressure"=>1013.46,
     "pressure_trend"=>"falling",
     "temperature"=>-0.89,
     "temperature_apparent"=>-7.4,
     "temperature_dew_point"=>-2.63,
     "uv_index"=>0,
     "visibility"=>1662.17,
     "wind_direction"=>204,
     "wind_gust"=>50.14,
     "wind_speed"=>19.62},
   "forecast_daily"=>
    {"days"=>
      [{"condition_code"=>nil,
        "daytime_forecast"=>nil,
        "forecast_end"=>nil,
        "forecast_start"=>nil,
        "max_uv_index"=>nil,
        "moon_phase"=>nil,
        "moonrise"=>"2024-12-26T11:25:41Z",
        "moonset"=>"2024-12-26T21:24:16Z",
        "overnight_forecast"=>nil,
        "precipitation_amount"=>nil,
        "precipitation_chance"=>nil,
        "precipitation_type"=>nil,
        "snowfall_amount"=>nil,
        "solar_midnight"=>nil,
        "solar_noon"=>nil,
        "sunrise"=>"2024-12-26T15:19:25Z",
        "sunrise_astronomical"=>nil,
        "sunrise_civil"=>nil,
        "sunrise_nautical"=>nil,
        "sunset"=>"2024-12-27T00:44:18Z",
        "sunset_astronomical"=>nil,
        "sunset_civil"=>nil,
        "sunset_nautical"=>nil,
        "temperature_max"=>nil,
        "temperature_min"=>nil},
       {"condition_code"=>nil,
        "sunrise"=>"2024-12-27T15:19:44Z", ... },
       {"condition_code"=>nil,
        "sunrise"=>"2024-12-28T15:20:00Z", ... },
       ...
     "learn_more_url"=>nil},
     "learn_more_url"=>nil},
   "forecast_hourly"=>
    {"hours"=>
      [{"forecastStart"=>"2024-12-26T07:00:00Z",
        "cloudCover"=>0.83,
        "conditionCode"=>"MostlyCloudy",
        "daylight"=>false,
        "humidity"=>0.8,
        "precipitationAmount"=>0.0,
        "precipitationIntensity"=>0.0,
        "precipitationChance"=>0.0,
        "precipitationType"=>"clear",
        "pressure"=>1020.97,
        "pressureTrend"=>"falling",
        "snowfallIntensity"=>0.07,
        "snowfallAmount"=>0.07,
        "temperature"=>0.54,
        "temperatureApparent"=>-0.51,
        "temperatureDewPoint"=>-2.52,
        "uvIndex"=>0,
        "visibility"=>28304.39,
        "windDirection"=>199,
        "windGust"=>18.85,
        "windSpeed"=>7.3},
       {"forecastStart"=>"2024-12-26T08:00:00Z", ... },
       {"forecastStart"=>"2024-12-26T09:00:00Z", ... },
   "forecast_next_hour"=>{},
   "weather_alerts"=>{}}}
```

### Looking at forcast data

Currrently show min/max temperature for the hourly forecast and just
the temperature for the 5-day forecast. Will need to flip the data around.

```rb
data = wk_api.forecast(lat: lat, lon: lon)

data["forecastHourly"]["hours"].size => 249
data["forecastHourly"]["hours"].map {|o| [o["forecastStart"], o["temperature"]] }
 =>
[["2025-01-05T05:00:00Z", 20.44],
 ...
 ["2025-01-05T06:00:00Z", 20.31],
 ["2025-01-06T06:00:00Z", 18.57],
 ["2025-01-07T06:00:00Z", 19.35],
 ["2025-01-08T06:00:00Z", 19.59],
 ["2025-01-09T06:00:00Z", 19.58],
 ["2025-01-10T06:00:00Z", 18.43],
 ["2025-01-11T06:00:00Z", 17.69],
 ["2025-01-12T06:00:00Z", 19.03],
 ["2025-01-13T06:00:00Z", 14.64],
 ["2025-01-14T06:00:00Z", 15.82],
 ...
 ["2025-01-15T12:00:00Z", 12.7],
 ["2025-01-15T13:00:00Z", 15.51]]

data["forecastDaily"]["days"].map {|o| [o["forecastStart"], o["forecastEnd"],
   o["daytimeForecast"]["forecastStart"], o["daytimeForecast"]["forecastEnd"],
   o["overnightForecast"]["forecastStart"], o["overnightForecast"]["forecastEnd"]] }
 =>
[["2025-01-05T06:00:00Z", "2025-01-06T06:00:00Z",
  "2025-01-05T13:00:00Z", "2025-01-06T01:00:00Z",  # 1/5, 1pm - 1/6, 1am
  "2025-01-06T01:00:00Z", "2025-01-06T13:00:00Z"], # 1/6, 1am - 1/6, 1pm
 ["2025-01-06T06:00:00Z", "2025-01-07T06:00:00Z",
  "2025-01-06T13:00:00Z", "2025-01-07T01:00:00Z",  # 1/6, 1pm - 1/7, 1am
  "2025-01-07T01:00:00Z", "2025-01-07T13:00:00Z"], # 1/7, 1am - 1/7, 1pm
 ...
 ["2025-01-14T06:00:00Z", "2025-01-15T06:00:00Z",
  "2025-01-14T13:00:00Z", "2025-01-15T01:00:00Z",  # 1/14, 1pm - 1/15, 1am
  "2025-01-15T01:00:00Z", "2025-01-15T13:00:00Z"]] # 1/15, 1am - 1/15, 1pm
```

### Attribution

WeatherKit REST API attribution logo when not using the Swift wrappers
- https://developer.apple.com/weatherkit/#attribution-requirements
- https://forums.developer.apple.com/forums/thread/708013
