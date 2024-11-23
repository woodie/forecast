# forecast
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
rails new forecast --skip-git
```

More rubygems added (including rspec) to Gemfile.
```
rails generate rspec:install
```

### Generating the app

We can generate most of the app.

```sh
rails g scaffold Place city state country country_code postal_code \
    lat:float lon:float current_weather:json weather_forecast:json

```
