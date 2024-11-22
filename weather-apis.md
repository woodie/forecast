# Weather data and addresses

We will retrieve current temperature for the given address,
as well as high/low and/or extended forecast.
We will cache the forecast by zip code.

### OpenWeatherMap library

Working directly with the National Weather Service (NWS) could work,
and there are [lots of rubygems](https://rubygems.org/search?query=NOAA)
that use NOAA data. OpenWeatherMap works and has what we need.

```rb
require 'openweathermap'
require 'dotenv'; Dotenv.load('.env')
api = OpenWeatherMap::API.new(ENV['openweather_api_key'], 'en', 'metric')

api.current('Truckee,US').weather_conditions.temperature => 6.72
api.current('Truckee,US').weather_conditions.temp_min => 4.58
api.current('Truckee,US').weather_conditions.temp_max => 6.01
```

### Address geocoding

We can evaluate data from a couple resorts to understand granularity:
* Northstar: 5001 Northstar Dr, Truckee, CA 96161
* Palisades: 1960 Olympic Vly Rd, Olympic Valley, CA 96146

We can fetch our own lat/lon data for comparison.

```rb
require 'geocoder'
Geocoder.search("Truckee,US").first.coordinates
=> [39.327962, -120.1832533]

Geocoder.search('Northstar Dr, Truckee, CA 96161').first.coordinates
=> [39.29167355, -120.11588443470491]
Geocoder.search('96161,CA').first.coordinates
=> [39.3271383086758, -120.1904837041096]
Geocoder.search('Olympic Heights,CA').first.coordinates
=> [39.3355407, -120.1553372]

Geocoder.search('Olympic Valley, CA 96146').first.coordinates
=> [39.1984156, -120.2298597]
Geocoder.search('96146,CA').first.coordinates
=> [39.204006191860465, -120.22210241860466]
Geocoder.search('Rampart,CA').first.coordinates
=> [39.164629, -120.1782485]
```

With a valid zip code, we can just ignore the rest of the address.

```rb
require 'openweathermap'
require 'dotenv'; Dotenv.load('.env')
api = OpenWeatherMap::API.new(ENV['openweather_api_key'], 'en', 'metric')

api.current('96161,US').weather_conditions.temperature => 6.64
api.current('96161,US').city.name => "Olympic Heights"
api.current('96161,US').city.coordinates => @lat=39.3357, @lon=-120.1577

api.current('96146,US').weather_conditions.temperature => 6.29
api.current('96146,US').city.name => "Rampart"
api.current('96146,US').city.coordinates => @lat=39.1646, @lon=-120.1782
```

OpenWeatherMap geocoding from zip code appears to be associated
with the location of the meteorological equipment.

With an address validation API we can look up a zip code,
but our first pass can simply require a valid zip code.

### Bad data and errors

Evaluate what happens with bad locations.

```rb
require 'geocoder'
Geocoder.search("").first => nil
Geocoder.search("1").first => nil
Geocoder.search("12345").first.address # coordinates
=> "12345, Suez, Egypt"
=> [29.77471933333333, 32.06033086666667]
Geocoder.search("No Place, CA 99999").first.address # coordinates
=> "No Place, Husick Estates, Charles County, Maryland, 20646, United States"
=> [38.473558477132535, -76.89992917748731]
Geocoder.search("99999,US").first.address # coordinates
=> "99999, Morgan County, Ohio, United States"
=> [39.73764905652174, -81.84079024347827]

require 'openweathermap'
require 'dotenv'; Dotenv.load('.env')
api = OpenWeatherMap::API.new(ENV['openweather_api_key'], 'en', 'metric')
api.current('99999,US')
=> unknown location. API message : 99999,US (OpenWeatherMap::Exceptions::UnknownLocation)
```

The geocoder is a bit aggressive/creative when converting a nonsense address.
UnknownLocation exceptions from OpenWeatherMap can be treated as a bad zip code.

```rb
require 'Indirizzo'
Indirizzo::Address.new("").zip => no text provided (ArgumentError)
Indirizzo::Address.new("1").zip => ""
Indirizzo::Address.new("Truckee CA").zip => ""
Indirizzo::Address.new("9999,US").zip => ""
Indirizzo::Address.new("99999-1234,US").zip => "99999"
Indirizzo::Address.new("99999, Morgan County, Ohio, United States").zip => "99999"
```

We can use an existing library to reliably extract zip codes, once we have at least 5 characters.
