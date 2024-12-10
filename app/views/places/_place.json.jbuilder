json.extract! place, :id, :city, :state, :country, :country_code, :postal_code, :lat, :lon, :current_weather, :weather_forecast, :created_at, :updated_at
json.url place_url(place, format: :json)
