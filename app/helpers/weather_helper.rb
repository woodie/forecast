module WeatherHelper
  def icon_tag(code, klass = "", alt = "icon")
    image_tag "https://openweathermap.org/img/wn/#{code}@2x.png",
      alt: alt, title: alt, class: klass
  end

  def icon_svg(opt, force_neutral = false)
    filename = WeatherImage.image opt["main"], force_neutral ? nil : opt["icon"].end_with?("d")
    image_tag "#{WeatherImage::PATH}/#{filename}.svg",
      alt: opt["description"], title: opt["description"], class: "weather-image"
  end

  def icon_css(opt, force_neutral = false)
    return "wi wi-owm-#{opt["id"]}" if WeatherIcon::NEUTRAL.include?(opt["id"]) || force_neutral
    "wi wi-owm-#{opt["icon"].end_with?("d") ? :day : :night}-#{opt["id"]}"
  end

  def time_format(datetime, timezone = "America/Los_Angeles", fmt = "%-l:%M%P")
    Time.at(datetime).in_time_zone(timezone).strftime(fmt)
  end

  # Few countries are exclusively using Fahrenheit
  def temp_format(kelvin_temp, country_code = "us")
    return "n/a" if kelvin_temp.nil?
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
