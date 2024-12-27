OpenWeatherAPI.configure do |config|
  config.api_key = ENV['OPENWEATHER_API_KEY']
  config.default_country_code = 'us'
end

__END__

class Float
  def to_celsius # from Kelvin
    (self - 273.15).round(2)
  end 

  def to_fahrenheit # from Kelvin
    (to_celsius * 1.8 + 32).round(2)
  end
end
