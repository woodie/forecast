class WeatherImage
  # https://github.com/Makin-Things/weather-icons
  PATH = "https://raw.githubusercontent.com/Makin-Things/weather-icons/master/animated"
  MAP = {
    Clear: %w[clear-day clear-night clear-day],
    MostlyClear: :Clear,
    Hot: %w[clear-day],
    Cloudy: %w[cloudy-3-day cloudy-3-night cloudy],
    PartlyCloudy: :Cloudy,
    MostlyCloudy: %w[cloudy],
    Dust: %w[dust],
    Fog: %w[fog-day fog-night fog],
    Smoke: :Fog,
    Frigid: %w[frost-day frost-night frost],
    Hail: %w[hail],
    Haze: %w[haze-day haze-night haze],
    Hurricane: %w[hurricane],
    ScatteredThunderstorms: %w[scattered-thunderstorms-day
      scattered-thunderstorms-night scattered-thunderstorms],
    IsolatedThunderstorms: %w[isolated-thunderstorms-day
      isolated-thunderstorms-night isolated-thunderstorms],
    SevereThunderstorm: %w[severe-thunderstorm],
    Thunderstorm: %w[thunderstorms],
    Drizzle: %w[rainy-1-day rainy-1-night rainy-1],
    Rain: %w[rainy-2-day rainy-2-night rainy-2],
    HeavyRain: :Rain,
    Showers: %w[rainy-3-day rainy-3-night rainy-3],
    ScatteredShowers: :Showers,
    TropicalStorm: %w[tropical-storm],
    MixedRainAndSleet: %w[rain-and-sleet-mix],
    MixedRainfall: :MixedRainAndSleet,
    Sleet: :MixedRainAndSleet,
    MixedRainAndSnow: %w[snow-and-sleet-mix],
    MixedSnowAndSleet: %w[rain-and-snow-mix],
    FreezingDrizzle: :MixedSnowAndSleet,
    FreezingRain: :MixedSnowAndSleet,
    Flurries: %w[snowy-1-day snowy-1-night snowy-1],
    ScatteredSnowShowers: :Flurries,
    Snow: %w[snowy-2-day snowy-2-night snowy-2],
    SnowShowers: :Snow,
    HeavySnow: %w[snowy-3-day snowy-3-night snowy-3],
    BlowingSnow: :HeavySnow,
    Blizzard: :HeavySnow,
    Tornado: %w[tornado],
    Windy: %w[wind],
    Breezy: :Windy
  }

  def self.image(code, is_day)
    mapping = MAP[code.to_sym] || MAP[:Clear]
    mapping = MAP[mapping] if mapping.is_a? Symbol
    return mapping.last if mapping.size < 2 || is_day.nil?
    is_day ? mapping[0] : mapping[1]
  end
end
