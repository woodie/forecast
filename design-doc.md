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

- The Place controller will process the transactions
- Raise InvalidAddress exception when Geocoder returns a null place
- Fetch `current_weather` and `weather_forecast` independently
- Raise WeatherUnavailable exception if OpenWeatherAPI fails
- Cache each weather objects for 30 minutes and provide indicator
- Will need database index on `country_code` and `postal_code`
- Entering a new address will reset the UI.
- Tests can mock APIs with webmock (instead of vcr)

### UI considerations

Use HTML5/CSS and ERB with some JS to keep things simple.
Highlight temperature as it was the core element requested, as well as
rendering the main attribute (clouds, drizzle, snow) icon/emoji.
To meet the forecast requirement, we can simply show information for tomorrow.

- Show date/time and 'next refresh' information as indicator
- Show the name of the place including postal and country codes
- Show icon, temp in °F with max/min after
- Repeat the same information for tomorrow forecast
- Display in localtime for current and tomorrow forecast

We should use [better icons](https://github.com/hasankoroglu/OpenWeatherMap-Icons).

### Example UI

```
.---------------------.
|                     |
|  City, ZIP, COUNTY  |
|     <icon> 57°F     |
|   Feels Like: 62°   |
|     H:66° L:43°     |
| time & next refresh |
|                     |
|    8am <icon> 57°   |
|   11am <icon> 60°   |
|    2pm <icon> 63°   |
|    5pm <icon> 60°   |
|    8pm <icon> 57°   |
|   11pm <icon> 50°   |
|                     |
'---------------------'
```

### App schema

The Place will include attributes from the Geocoder API and
reference the current weather and forecasts will reference Place.
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

docs: https://rubydoc.info/gems/open-weather-api
repo: https://gitlab.com/wikiti-random-stuff/open-weather-api
mock: https://thoughtbot.com/blog/how-to-stub-external-services-in-tests
