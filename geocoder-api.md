# Geocoder API

When a real place does not have a postal code, 
we can display, "Sorry, this location does not have a postal code."
Caching by `place_id` (which does not meet the requirements)
would be acoid this corner case, but would blow up the cache size.

### Address geocoding

```rb
require 'geocoder'
Geocoder.search("Truckee,US").first.postal_code
=> nil
Geocoder.search(Geocoder.search("Truckee,US").first.coordinates).first.postal_code
=> "96161"

Geocoder.search('Northstar Dr, Truckee, CA 96161').first.coordinates
=> [39.29167355, -120.11588443470491]
Geocoder.search('96161,CA').first.coordinates
=> [39.3271383086758, -120.1904837041096]

Geocoder.search('Olympic Valley, CA 96146').first.coordinates
=> [39.1984156, -120.2298597]
Geocoder.search('96146,CA').first.coordinates
=> [39.204006191860465, -120.22210241860466]

Geocoder.search("50122,US").first.display_name
=> "50122, Hubbard, Hardin County, Iowa, United States"
Geocoder.search("50122,IT").first.display_name
=> "50122, Quartiere 1, Florence, Tuscany, Italy"
```

To avoid collisions, we should including postal and country code as cache keys.
With a valid zip code, we can just ignore the rest of the address.

### Bad data and errors

Evaluate what happens with bad locations.
The geocoder can be creative when converting a nonsense address.

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

Geocoder.search("Antarctica").first.display_name
=> "Antarctica" 
Geocoder.search("Antarctica").first.postal_code
=> nil 
Geocoder.search("McMurdo Station, Antarctica")
=> [] 

Geocoder.search("North Pole").first.display_name
=> "North Pole, Fairbanks North Star, Alaska, United States" 
Geocoder.search("North Pole").first.postal_code
=> nil 
Geocoder.search("Flashline Mars Arctic Research Station").first.display_name
=> "Flashline Mars Arctic Research Station, Qikiqtaaluk Region, Nunavut, Canada" 
Geocoder.search("Flashline Mars Arctic Research Station").first.postal_code
=> nil 
```

Some real places won't have a postal code and some won't be found.

```rb
require 'geocoder'

Geocoder.search(Geocoder.search("Truckee,US").first.coordinates).first
#<Geocoder::Result::Nominatim:0x0000000106bd5860
 @cache_hit=nil,
 @data=
  {"place_id"=>298141676,
   "licence"=>"Data © OpenStreetMap contributors, ODbL 1.0. http://osm.org/copyright",
   "osm_type"=>"way",
   "osm_id"=>350491001,
   "lat"=>"39.32812335",
   "lon"=>"-120.18355330161927",
   "class"=>"amenity",
   "type"=>"fuel",
   "place_rank"=>30,
   "importance"=>5.597390707251114e-05,
   "addresstype"=>"amenity",
   "name"=>"Beacon",
   "display_name"=>"Beacon, Donner Pass Road, Truckee, Nevada County, California, 96161, United States",
   "address"=>
    {"amenity"=>"Beacon",
     "road"=>"Donner Pass Road",
     "town"=>"Truckee",
     "county"=>"Nevada County",
     "state"=>"California",
     "ISO3166-2-lvl4"=>"US-CA",
     "postcode"=>"96161",
     "country"=>"United States",
     "country_code"=>"us"},
   "boundingbox"=>["39.3279317", "39.3283287", "-120.1839330", "-120.1831741"]}>
```
