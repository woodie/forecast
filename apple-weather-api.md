# Apple Weather API

We will retrieve current temperature for the given address,
as well as high/low and extended forecast.
We will cache the forecast by zip (postal) code.

### TenKit library

The TenKit library handles configuration but is not complete.
We could instead generate a JWT (using your private key and the Service ID)
and then talk diretly to the JSON API passing the encoded JWT as a Bearer Token.
```
https://weatherkit.apple.com/api/v1/weather/en/{lat}/{lon}?dataSets=forecastDaily&timezone=America/Los_Angeles
```

We can work with both weather APIs interchangeably but use the same minimal format
or we can provide an ERB template for each data source.

We can convert [condition code](https://github.com/hrbrmstr/weatherkit/blob/batman/R/enumerations.R)
into the identifier for [open weather icons](https://openweathermap.org/weather-conditions)
or provide a conversion the other direction.

### Sample data

```rb
Tenkit.configure do |c|
  c.team_id = ENV["APPLE_DEVELOPER_TEAM_ID"]
  c.service_id = ENV["APPLE_DEVELOPER_SERVICE_ID"]
  c.key_id = ENV["APPLE_DEVELOPER_KEY_ID"]
  c.key =  ENV["APPLE_DEVELOPER_PRIVATE_KEY"]
end

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

client = Tenkit::Client.new
lat = 39.32812335
lon = -120.18355330161927
sets = [:current_weather, :forecast_daily, :forecast_hourly]

data = client.weather(lat, lon, sets)

data.weather.forecast_hourly.hours.size => 243
data.weather.forecast_hourly.hours.first["forecastStart"] => "2024-12-27T07:00:00Z"
data.weather.forecast_hourly.hours.first['temperature'] => -0.63
data.weather.forecast_hourly.hours.last["forecastStart"] => "2025-01-06T09:00:00Z"
data.weather.forecast_hourly.hours.last['temperature'] => -4.14

data.weather.forecast_daily.days.size => 9
data.raw["forecastDaily"]["days"].first["forecastStart"] => "2024-12-27T08:00:00Z"
data.raw["forecastDaily"]["days"].first["temperatureMin"] => -0.95
data.raw["forecastDaily"]["days"].first["temperatureMax"] => 4.84
data.raw["forecastDaily"]["days"].last["forecastStart"] => "2025-01-04T08:00:00Z"
data.raw["forecastDaily"]["days"].last["temperatureMin"] => -1.28
data.raw["forecastDaily"]["days"].last["temperatureMax"] => 7.09

# With bugus credentials

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
         {"forecastStart"=>"2024-12-27T03:00:00Z",
          "forecastEnd"=>"2024-12-27T15:00:00Z",
          "cloudCover"=>0.93,
          "conditionCode"=>"HeavySnow",
          "humidity"=>0.89,
          "precipitationAmount"=>12.25,
          "precipitationChance"=>1.0,
          "precipitationType"=>"snow",
          "snowfallAmount"=>101.92,
          "temperatureMax"=>2.01,
          "temperatureMin"=>-0.94,
          "windDirection"=>219,
          "windGustSpeedMax"=>71.95,
          "windSpeed"=>18.31,
          "windSpeedMax"=>25.06},
        "restOfDayForecast"=>
         {"forecastStart"=>"2024-12-27T07:44:39Z",
          "forecastEnd"=>"2024-12-27T08:00:00Z",
          "cloudCover"=>0.96,
          "conditionCode"=>"HeavySnow",
          "humidity"=>0.88,
          "precipitationAmount"=>0.44,
          "precipitationChance"=>0.33,
          "precipitationType"=>"snow",
          "snowfallAmount"=>4.54,
          "temperatureMax"=>-0.89,
          "temperatureMin"=>-0.94,
          "windDirection"=>204,
          "windGustSpeedMax"=>52.32,
          "windSpeed"=>19.94,
          "windSpeedMax"=>20.27}},
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
       {"condition_code"=>nil, "sunrise"=>"2024-12-27T15:19:44Z", ... },
       {"condition_code"=>nil, "sunrise"=>"2024-12-28T15:20:00Z", ... },
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