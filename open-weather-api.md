# Open Weather API

We will retrieve current temperature for the given address,
as well as high/low and extended forecast.
We will cache the forecast by zip (postal) code.

### Open Weather library

Working directly with the National Weather Service (NWS) could work,
and there are [lots of rubygems](https://rubygems.org/search?query=NOAA)
that use NOAA data. 

- `open-weather-ruby-client`: Modern and powerful but no free forecast API
- `openweathermap`: Popular but stale could require we marshall objects
- `open-weather-api`: Stale with some broken features, but has interface to JSON

OpenWeatherAPI is free and has what we need.

UPDATE: Migrating to Apple WeatherKit just for fun.

### Address geocoding

We can assume the Geocoder will not return a bad zip code, but handle it.
The Apple WeatherKit takes a lat/lon. The legacy behaviour can be simple too.

```rb
open_weather_api = Rails.configuration.open_weather_api
open_weather_api.current zipcode: '99999', country_code: 'us'
(forecast):5:in `<main>': 404 Not Found (RestClient::NotFound)
```

We can work directly with JSON using the OpenWeatherApi wrapper for Ruby.

```rb
open_weather_api = Rails.configuration.open_weather_api

open_weather_api.current zipcode: '96161', country_code: 'us'
 => 
{"coord"=>{"lon"=>-120.1729, "lat"=>39.3385},
 "weather"=>[{"id"=>600, "main"=>"Snow", "description"=>"nevada ligera", "icon"=>"13d"}],
 "base"=>"stations",
 "main"=>{"temp"=>274.24, "feels_like"=>270.88, "temp_min"=>273.29, "temp_max"=>276.94, "pressure"=>1018, "humidity"=>86, "sea_level"=>1018, "grnd_level"=>786},
 "visibility"=>10000,
 "wind"=>{"speed"=>3.09, "deg"=>200},
 "snow"=>{"1h"=>0.5},
 "clouds"=>{"all"=>75},
 "dt"=>1732656764,
 "sys"=>{"type"=>1, "id"=>6071, "country"=>"US", "sunrise"=>1732633034, "sunset"=>1732667974},
 "timezone"=>-28800,
 "id"=>0,
 "name"=>"Truckee",
 "cod"=>200} 

open_weather_api.forecast(lat:39.3385, lon: -120.1729)[:list].size
 => 40

open_weather_api.forecast(lat:39.3385, lon: -120.1729)
 => 
{"cod"=>"200",
 "message"=>0,
 "cnt"=>40,
 "list"=>
  [{"dt"=>1732665600,
    "main"=>
     {"temp"=>273.64,
      "feels_like"=>269.85,
      "temp_min"=>272.38,
      "temp_max"=>273.64,
      "pressure"=>1019,
      "sea_level"=>1019,
      "grnd_level"=>787,
      "humidity"=>90,
      "temp_kf"=>1.26},
    "weather"=>[{"id"=>600, "main"=>"Snow", "description"=>"nevada ligera", "icon"=>"13d"}],
    "clouds"=>{"all"=>83},
    "wind"=>{"speed"=>3.47, "deg"=>245, "gust"=>8.78},
    "pop"=>1,
    "snow"=>{"3h"=>0.81},
    "sys"=>{"pod"=>"d"},
    "dt_txt"=>"2024-11-27 00:00:00"},
    ...
  ]
}
```

Although OpenWeatherApi is old and a bit broken, it provides one forecast API that's free.

### License and attribution

For the Free plan, unclear is the attribution requirement is obligatory.

- Text that reads 'Weather data provided by OpenWeather’
- Hyperlink to 'https://openweathermap.org/'

https://openweathermap.org/faq
