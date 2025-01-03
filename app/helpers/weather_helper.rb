module WeatherHelper
  def icon_url(code, alt = "icon")
    image_tag "/ow/#{code}@2x.png", alt: alt, title: alt, class: "weather-icon"
  end

  # Can do more with localtime format
  def time_format(datetime, timezone = 'America/Los_Angeles', fmt = "%-l:%M%P")
    Time.at(datetime).in_time_zone(timezone).strftime(fmt)
  end

  # Few countries are exclusively using Fahrenheit
  def temp_format(kelvin_temp, country_code = "us")
    if %w[us ky].include?(country_code.downcase)
      "#{to_fahrenheit(kelvin_temp).round}°F"
    else
      "#{to_celsius(kelvin_temp).round}°C"
    end
  end

  private

  def to_celsius(kelvin_temp)
    (kelvin_temp - 273.15).round(2)
  end

  def to_fahrenheit(kelvin_temp)
    (to_celsius(kelvin_temp) * 1.8 + 32).round(2)
  end
end
