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

Will use the most current version of Rails
with OpenWeatherMap and Geocoder rubygems.

- The forecast controller will process the transactions
- Raise InvalidAddress exception when Geocoder or OpenWeatherMap return null place
- Cache each weather object for 30 minutes and provide indicator
  with SQLite using a timestamp (should also evaluate using Rails.cache)
- The Forecast models will need an index on postal and country codes
- Entering a new address will reset the UI. We could add a spinner

### UI considerations

We can use HTML5/CSS and ERB with a touch of VanillaJS to keep things simple.
We have the baseline UI from OpenWeather as creative input (see baseline-ui.png).
We will highlight temperature as it was the core element requested, as well as
rendering the main attribute (clouds, drizzle, snow, etc.) and icon/emoji.
To meet the forecast requirement, we can simply show information for tomorrow.

- Show date/time and 'next refresh' information as indicator
- Show the name of the place including postal and country codes
- Show icon, temp in °F with max/min after
- Repeat the same information for tomorrow forecast
- Display in localtime for current and tomorrow forecast

### Local schema

We will cache current and forecast data from the API as Weather.
A Place will include attributes from the Geocoder API and
reference the current weather and forecasts will reference Place.

Once we create a place, it should not require continuous updating.
We will need to update the associated "current weather" and
"weather forecast" which is an array of associated weather objects.

```
Place
 name
 display_name
 facility_name
 town
 state
 postal_code
 country_code
 current_weather_id:integer

Weather
  description
  emoji
  icon
  main
  clouds:float
  humidity:float
  pressure:float
  temp_max:float
  temp_min:float
  temperature:float
  time:timestamp
  forecast:boolean
  place:references
```

### Sample API data

For reference, here is what Geocoder and OpenWeatherMap APIs return.

```rb
require 'geocoder'
Geocoder.search("96161,US").first
 =>
#<Geocoder::Result::Nominatim:0x0000000106de7608
 @cache_hit=nil,
 @data=
  {"place_id"=>353662656,
   "licence"=>"Data © OpenStreetMap contributors, ODbL 1.0. http://osm.org/copyright",
   "lat"=>"39.3271383086758",
   "lon"=>"-120.1904837041096",
   "class"=>"place",
   "type"=>"postcode",
   "place_rank"=>21,
   "importance"=>0.12000999999999995,
   "addresstype"=>"postcode",
   "name"=>"96161",
   "display_name"=>"96161, Truckee, Nevada County, California, United States",
   "address"=>
    {"postcode"=>"96161",
     "town"=>"Truckee",
     "county"=>"Nevada County",
     "state"=>"California",
     "ISO3166-2-lvl4"=>"US-CA",
     "country"=>"United States",
     "country_code"=>"us"},
   "boundingbox"=>["39.2771383", "39.3771383", "-120.2404837", "-120.1404837"]}>

require 'openweathermap'
require 'dotenv'; Dotenv.load('.env')
api = OpenWeatherMap::API.new(ENV['openweather_api_key'], 'en', 'imperial')

api.current('Truckee,US')
 =>
#<OpenWeatherMap::CurrentWeather:0x000000010503a308
 @city=
  #<OpenWeatherMap::City:0x0000000105039b38
   @coordinates=#<OpenWeatherMap::Coordinates:0x0000000105039b10 @lat=39.328, @lon=-120.1833>,
   @country="US",
   @name="Truckee">,
 @weather_conditions=
  #<OpenWeatherMap::WeatherConditions:0x0000000105039a98
   @clouds=100.0,
   @description="drizzle",
   @emoji="🌧",
   @humidity=89.0,
   @icon="https://openweathermap.org/img/w/09d.png",
   @main="Drizzle",
   @pressure=1015.0,
   @rain={:one_hour=>0.23, :three_hours=>nil},
   @snow=nil,
   @temp_max=42.96,
   @temp_min=36.0,
   @temperature=38.37,
   @time=2024-11-22 16:15:53 -0800,
   @wind={:speed=>11.5, :direction=>200}>>

api.forecast('Truckee,US').forecast.size => 40

api.forecast('Truckee,US').forecast
 => [ # weather_conditions at these times
  @time=2024-11-22 19:00:00 -0800,
  @time=2024-11-22 22:00:00 -0800,
  @time=2024-11-23 01:00:00 -0800,
  ...
  @time=2024-11-27 10:00:00 -0800,
  @time=2024-11-27 13:00:00 -0800,
  @time=2024-11-27 16:00:00 -0800]
```

### Copyright and License

The Geocoder requires that we credit OpenStreetMap and contributors.
- Data © OpenStreetMap(http://osm.org/copyright) contributors, ODbL 1.0
