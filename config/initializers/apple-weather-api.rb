Tenkit.configure do |c|
  c.team_id = ENV["APPLE_DEVELOPER_TEAM_ID"]
  c.service_id = ENV["APPLE_DEVELOPER_SERVICE_ID"]
  c.key_id = ENV["APPLE_DEVELOPER_KEY_ID"]
  c.key = ENV["APPLE_DEVELOPER_PRIVATE_KEY"]
end

module Tenkit
  class Client
    def weather(lat, lon, data_sets = [:current_weather], language = "en") # patch required
      path_root = "/weather/#{language}/#{lat}/#{lon}?dataSets="
      path = path_root + data_sets.map { |ds| DATA_SETS[ds] }.compact.join(",")
      response = get(path)
      WeatherResponse.new(response)
    end
  end
end
