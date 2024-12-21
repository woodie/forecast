require "geocoder"

class WeatherController < ApplicationController
  protect_from_forgery

  def result
    query = params[:search][:address].strip
    unless query.present? && query.length >= 5
      flash[:notice] = "Sorry, '#{query}' is not a minimun of 5 characters."
      return redirect_to root_path
    end

    address = Address.find_by(query: query.downcase)
    if address.present?
      @place = address.place
    else
      coordinates = Geocoder.search(query).first&.coordinates
      unless coordinates.present?
        flash[:notice] = "Sorry, '#{query}' is not a valid address."
        return redirect_to root_path
      end

      geo = Geocoder.search(coordinates).first
      unless geo.present? && geo.postal_code.present?
        flash[:notice] = "Sorry, '#{query}' does not have a postal code."
        return redirect_to root_path
      end

      @place = Place.geo_create(geo)
      Address.find_or_create_by(query: query.downcase, place: @place)
    end

    begin
      @fresh_data = @place.refresh_weather
    rescue => err
      # Rails.logger = Logger.new("OpenWeatherAPI responded with: #{err}")
      flash[:notice] = "Sorry, weather service cannot process request."
      redirect_to root_path
    end
  end
end
