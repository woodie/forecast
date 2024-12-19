class AddIndexToPlacesOnPostalCodeAndCountryCode < ActiveRecord::Migration[8.0]
  def change
    add_index :places, [:postal_code, :country_code]
  end
end
