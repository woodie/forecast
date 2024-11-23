# Forecast design document

### Requirements

We assume we can limit to US locations as caching uses zip code.
- Accept an address as input
- Retrieve forecast data for the given address
  - Include the current temperature with high/low and extended forecast
- Display the requested forecast details
- Cache the forecast details for 30 minutes by zip codes
  - Display indicator if result is pulled from cache

### Implementation

Will use the most current version of Rails
with OpenWeatherMap, Geocoder and Indirizzo rubygems.

- The forecast controller will process the transactions
- [OPTIONAL] Raise AddressTooShort exception when string is under 5 characters,
  and POST somehow slipped past browser checks
- Raise InvalidAddress exception When Indirizzo returns null address
- Raise UnknownAddress exception When Indirizzo returns null address.zip
  and Geocoder is unable to locate a US address
- Cache each forecast object for 30 minutes and provide indicator
  with SQLite using a timestamp (should also evaluate using Rails.cache)
- The Forecast models will need an index on zip code
- Entering a new address will reset the UI. We could add a spinner

### UI considerations

We can use HTML5/CSS and ERB with a touch of VanillaJS to keep things simple.
We have the baseline UI from OpenWeather as creative input (see baseline-ui.png).
We will highlight temperature as it was the core element requested, as well as
rendering the `main` attribute (clouds, drizzle, snow, etc.) and icon/emoji.
To meet the forecast requirement, we can simply show information for tomorrow.

- Show date/time and 'next refresh' information as indicator
- Show City Name and "US" next
- Show icon, temp in °F with max/min after
- Repeat the same information for tomorrow forecast
- Display in localtime for current and tomorrow forecast

### Sample API data

For quick reference, here is what OpenWeatherMap API returns.

```rb
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
  @time=2024-11-23 04:00:00 -0800,
  ...
  @time=2024-11-27 07:00:00 -0800,
  @time=2024-11-27 10:00:00 -0800,
  @time=2024-11-27 13:00:00 -0800,
  @time=2024-11-27 16:00:00 -0800]
```
