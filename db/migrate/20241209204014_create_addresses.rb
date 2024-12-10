class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.string :query
      t.references :place, null: false, foreign_key: true

      t.timestamps
    end
  end
end
