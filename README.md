# Weather Forecast
Display the weather forecast for any location.

**UPDATE:** The initial assignment is done but we're adding WeatherKit support for fun.

We use [Geocoder API](geocoder-api.md) to convert an address to a place.

We use [Open Weather API](open-weather-api.md) but can now also
use [Apple WeatherKit API](apple-weather-api.md).

- Open Weather (free) forcast only provides a snapshot every three hours.
- Apple WeatherKit hourly provides temperature and daily provides min/max.
  This is opposite from what the initial implementation renders.

Set `:use_wk_api` fo false in `config/feature.yml` to use the OpenWeather API.

### Setup and configuration

Request some credentials.
- [Open Weather API key](https://home.openweathermap.org/api_keys)
- [Several IDs and a PKEY](https://github.com/superbasicxyz/tenkit)

```sh
cat.env
OPENWEATHER_API_KEY=0123456789abcdef0123456789abcdef

APPLE_DEVELOPER_TEAM_ID=A1A1A1A1A1
APPLE_DEVELOPER_SERVICE_ID=com.mydomain.myapp
APPLE_DEVELOPER_KEY_ID=B2B2B2B2B2
APPLE_DEVELOPER_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----
0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
01234567
-----END PRIVATE KEY-----"
```

### Installing software

Rails 8.0.0 requires Ruby version >= 3.2.0.
```sh
rvm install 3.2.0 --with-openssl-dir=$(brew --prefix openssl@1.1)
gem install rails

rails s
```

<img src="https://raw.githubusercontent.com/woodie/forecast/master/truckee.png" height="700px"> &nbsp;
<img src="https://raw.githubusercontent.com/woodie/forecast/master/kyoto.png" height="700px">

### Running Specs

```sh
rspec spec -fd

Feature
  use_wk_api
    when activated
      reports true
    when deactivated
      reports false

Tenkin::Client
  #current
    contains expected keys
  #forecast
    contains expected keys

WeatherHelper
  #icon_tag
    returns populated IMG tag
  #icon_css
    with a day icon
      returns wi day class
    with a night icon
      returns wi night class
      with neutral-only id
        returns wi neutral class
  #time_format
    with West Coast location
      returns formated string
    with East Coast location
      returns formated string
  #temp_format
    when passed nil
      returns n/a
    with fahrenheit country
      returns formated string
    with celsius country
      returns formated string
  #to_celsius
    returns converted float
  #to_fahrenheit
    returns converted float

Place
  .geo_create
    uses result attributes
    when state missing
      uses district
      when district missing
        uses province
  #refresh_weather
    when weather data is fresh
      should return false
    when weather data is stale
      when :use_wk_api is false
        should return true
      when :use_wk_api is true
        should return true
  #icon
    returns Open Weather icon
  #composite_main
    when rest_of_day weather_forecast missing
      returns main node from current weather
    when rest_of_day weather_forecast present
      returns composite main node with min and max
  #legacy_weather
    returns Open Weather payload
  #legacy_forecast
    with hourly feed missing min/max
      returns composite payload
    with daily feed missing temp
      returns composite payload
  #arrange_forecast
    with OW payload
      sets hourly and daily data
    with WK payload
      sets hourly and daily data
  #next_hour_at
    returns index to next hours data
    when all entries are in the past
      returns -1 to indicate bad data
  #m2k
    converts metric to kelvin
  #ow_api
    provides Open Weather api
  #wk_api
    provides Apple WeatherKit api

Weather
  GET /
    renders search page
  POST /
    with too few characters of input
      redirects to search page with flash message
    with geocoder processing addresses
      with unknown/invalid address
        redirects to search page with flash message
      with no postal code at address
        redirects to search page with flash message
      with an existing place
        with current weather and forcast data
          renders the result page
        with a new place
          renders the result page
          with bad weather service credentials
            redirects to search page with flash message

WeatherController
  routing
    routes to #search
    routes to #result

weather/result
  renders attributes
```
