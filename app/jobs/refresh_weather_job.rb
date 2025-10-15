class RefreshWeatherJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # place.refresh_weather
    # update UI
  end
end
