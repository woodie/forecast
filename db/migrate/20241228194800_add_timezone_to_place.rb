class AddTimezoneToPlace < ActiveRecord::Migration[8.0]
  def up
    add_column :places, :timezone, :string
    tf = TimezoneFinder.create
    Place.all.each { |p| p.update timezone: tf.timezone_at(lat: p.lat, lng: p.lon) }
  end

  def down
    remove_column :places, :timezone
  end
end
