class WeatherIcon
  # https://erikflowers.github.io/weather-icons/
  NEUTRAL = [210, 310, 601, 602] + [771, 901, 905] # forced + no-d/n, see: /owm-codes.html & /icons
  ICON_ID = {Clear: 800, Cloudy: 802, Dust: 731, Fog: 741, Haze: 721, MostlyClear: 800,
             MostlyCloudy: 803, PartlyCloudy: 801, ScatteredThunderstorms: 200, Smoke: 711,
             Breezy: 771, Windy: 957, Drizzle: 500, HeavyRain: 310, Rain: 520, Showers: 520,
             Flurries: 600, HeavySnow: 601, MixedRainAndSleet: 310, MixedRainAndSnow: 611,
             MixedRainfall: 310, MixedSnowAndSleet: 611, ScatteredShowers: 520,
             ScatteredSnowShowers: 511, Sleet: 611, Snow: 600, SnowShowers: 601,
             Blizzard: 601, BlowingSnow: 601, FreezingDrizzle: 602, FreezingRain: 602,
             Frigid: 903, Hail: 906, Hot: 904, Hurricane: 902, IsolatedThunderstorms: 200,
             SevereThunderstorm: 210, Thunderstorm: 200, Tornado: 781, TropicalStorm: 200}
  # https://openweathermap.org/weather-conditions
  OW_TEXT = {ClearSky: 1, FewClouds: 2, ScatteredClouds: 3, BrokenClouds: 4,
             ShowerRain: 9, Rain: 10, Thunderstorm: 11, Snow: 13, Mist: 50}
  OW_ICON = {200 => 11, 210 => 11, 310 => 9, 500 => 10, 511 => 13, 520 => 9,
             600 => 13, 601 => 13, 602 => 10, 611 => 9, 800 => 1, 801 => 2,
             802 => 3, 803 => 4, 903 => 13, 904 => 1, 906 => 10} # default 50

  def self.icon(code, daylight = true)
    num = OW_ICON[number(code)] || 50
    "#{num.to_s.rjust(2, "0")}#{daylight ? "d" : "n"}"
  end

  def self.number(code)
    ICON_ID[code.to_sym]
  end
end
