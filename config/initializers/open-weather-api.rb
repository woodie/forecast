OpenWeatherAPI.configure do |config|
  config.api_key = ENV['openweather_api_key']
  config.default_country_code = 'us'
end

class Float
  def to_celsius # from Kelvin
    (self - 273.15).round(2)
  end 

  def to_fahrenheit # from Kelvin
    (to_celsius * 1.8 + 32).round(2)
  end
end
