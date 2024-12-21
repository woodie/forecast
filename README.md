# Forecast
Weather forecast for a given address.

### Setup and configuration

Requested an [API key](https://home.openweathermap.org/api_keys) and store the value.
```sh
cat.env
openweather_api_key=0123456789abcdef0123456789abcdef
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
