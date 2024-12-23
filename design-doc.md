# Forecast design document

### Requirements

Summary of requirements:

- Accept an address as input
- Retrieve forecast data for the given address
  - Include the current temperature with high/low and extended forecast
- Display the requested forecast details
- Cache the forecast details for 30 minutes by zip codes
  - Display indicator if result is pulled from cache

Will use postal and country codes as the identifier to avoid "zip code" collisions.

### Implementation

Will use the most current version of Rails with Geocoder and OpenWeatherApi rubygems.
- Will work with any address the geocoder can process,
  which resolves "123 123" to "Desamparados, Alajuela Province, Costa Rica"
- The Weather controller will process the transactions
- Handle exception when Geocoder returns a null place
- Fetch `current_weather` and `weather_forecast` in Place model
- Handle when exception when OpenWeatherAPI fails
- Cache each weather objects for 30 minutes and provide indicator
- Tests could mock APIs with webmock (instead of vcr),
  but that ended up more clumsy than manually mocking

### UI considerations

Use HTML5/CSS and ERB with some JS to keep things simple.
Highlight temperature as it was the core element requested.

- Show date/time and 'next refresh' information as indicator
- Show the name of the place including postal and country codes
- Show icon, temp in °F (or °C) with max/min after
- Repeat the same forecast information.
- Display in localtime for current and forecast data.

Things to consider in the future:
- Use [tenkit](https://github.com/superbasicxyz/tenkit) for Apple's WeatherKit API in Ruby
  and [jekyll](https://github.com/ZekeSnider/jekyll-apple-maps/) for Apple's geocoder.
- Provide a way to flip between °F/°C in JS
- Render the Place but put bckground the Weather API
  and update the page when the data is available.

We will use [better icons](https://github.com/hasankoroglu/OpenWeatherMap-Icons).

### Example UI

```
.---------------------.
|  City, ZIP, COUNTY  |
|     <icon> 57°F     |
|   Feels Like: 62°   |
|     H:66° L:43°     |
| Weather data from T |
|  Next refresh at T  | <= cache indicator
|                     |
|  8am <icon> 57°-66° |
| 11am <icon> 55°-63° |
|  2pm <icon> 62°-64° |
|  5pm <icon> 57°-66° |
|  8pm <icon> 55°-63° |
|    5-DAY FORECAST   |
| Thursday <icon> 57° |
| Friday   <icon> 56° |
| Saturday <icon> 55° |
| Sunday   <icon> 54° |
| Monday   <icon> 53° |
'---------------------'
```

### App schema

The Place will include attributes from the Geocoder API and
reference the current weather and forecasts.
Once we create a place, it should not require continuous updating.
We will cache current and forecast data from the API.

```
Place
  city
  state
  country
  country_code
  postal_code
  lat:float
  lon:float
  current_weather:json
  weather_forecast:json

Address
  query
  place:references
```

There are libraries to get `country` from `country_code`
but we can just stash it while we have it from the geocoder.
We can access lat/lon from the `current_weather` JSON,
but we may want to compare what we have from the geocoder
which could lead to a better understanding of the data.

### Copyright and License

The Geocoder requires that we credit OpenStreetMap and contributors.
- Data © OpenStreetMap(http://osm.org/copyright) contributors, ODbL 1.0

### Other Resources

- docs: https://rubydoc.info/gems/open-weather-api
- repo: https://gitlab.com/wikiti-random-stuff/open-weather-api
- mock: https://thoughtbot.com/blog/how-to-stub-external-services-in-tests
