class CreatePlaces < ActiveRecord::Migration[8.0]
  def change
    create_table :places do |t|
      t.string :city
      t.string :state
      t.string :country
      t.string :country_code
      t.string :postal_code
      t.float :lat
      t.float :lon
      t.json :current_weather
      t.json :weather_forecast

      t.timestamps
    end
  end
end
