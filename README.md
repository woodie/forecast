# Weather Forecast
Display the weather forecast for any location.

We use [Geocoder API](geocoder-api.md) to convert an address to a place.

We use [Open Weather API](open-weather-api.md) but can now also
use [Apple WeatherKit API](apple-weather-api.md).

- Open Weather (free) forcast only provides a snapshot every three hours.
- Apple WeatherKit hourly provides temperature and daily provides min/max.
  This is opposite from what the initial implementation renders.

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

WeatherHelper
  #icon_url
    returns populated IMG tag
  #time_format
    with West Coast location
      returns formated string
    with East Coast location
      returns formated string
  #temp_format
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
    when state present
      uses state
    when district present
      uses district
    when province present
      uses province
  #refresh_weather
    when weather data is fresh
      should return false
    when weather data is stale
      should return true
      when postal code not found
        should still return true
  #condition_code
    returns open weather codes
  #ow_api
    provides open weather api

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
      with valid postal address
        with bad openweather API key
          redirects to search page with flash message
        with current weather and forcast data
          renders the result page

WeatherController
  routing
    routes to #search
    routes to #result

weather/result
  renders attributes
```
