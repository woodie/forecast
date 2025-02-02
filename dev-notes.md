# Development Notes

We can capture development setup and code-generation here.

### Creating the app

We can generate the app to get started.
```sh
rails new forecast --skip-git

rails generate rspec:install
cat > config/initializers/generators.rb<< EOF 
Rails.application.config.generators do |g| 
  g.test_framework :rspec
end
EOF
```
See how controllers/specs should work in Rails8.
```sh
rails g scaffold Place city state country country_code postal_code \
    lat:float lon:float current_weather:json weather_forecast:json
rails g scaffold Address query place:references
rails g controller weather
```

Countries (with postal codes) exclusively using Fahrenheit:
- us: The United States
- ky: The Cayman Islands

Localtime can be extracted from the open-weather-api:
```rb
# Washington DC
t = Time.at(1733966196).localtime(-18000) => 2024-12-11 20:16:36 -0500 
# California
t = Time.at(1733966196).localtime(-28800) => 2024-12-11 17:16:36 -0800 
```

Dealing with fonts...
https://world.hey.com/aesmail/custom-fonts-in-production-in-rails-7-0-d3765485

Resetting the database greatly simplifies debugging schema.
```sh
rails db:migrate:reset
```
