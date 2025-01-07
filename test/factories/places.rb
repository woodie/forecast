FactoryBot.define do
  data = {coord: {lat: "39.3385", lon: "-120.1729"}, dt: 1732656764,
          weather: [{:id => 600, :main => "Snow", :description => "snow", "icon" => "13d"}],
          main: {temp: 284.26, feels_like: 283.70, temp_min: 283.15, temp_max: 284.82}}
  list = {"hourly" => Array.new(5) { data }, "daily" => Array.new(5) { data }}

  factory :place do
    city { "Truckee" }
    state { "California" }
    country { "United States" }
    country_code { "us" }
    postal_code { "96161" }
    lat { 39.3385 }
    lon { -120.1729 }
    timezone { "America/Los_Angeles" }

    trait :populated do
      current_weather { data }
      weather_forecast { list }
      created_at { Time.now }
      updated_at { Time.now }
    end

    factory :populated_place, traits: [:populated]
  end
end
