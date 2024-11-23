# Development Notes

We can capture development setup and code-generation here.

### Creating the app

We can generate the app to get started.
```sh
rails generate rspec:install
cat > config/initializers/generators.rb<< EOF 
Rails.application.config.generators do |g| 
  g.test_framework :rspec
end
EOF

rails g scaffold Place city state country country_code postal_code \
    lat:float lon:float current_weather:json weather_forecast:json
rails g scaffold Address query place:references
```
