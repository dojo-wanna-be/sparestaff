class CreateListingAvailabilities < ActiveRecord::Migration[5.2]
  def change
    create_table :listing_availabilities do |t|
      t.time :start_time
      t.time :end_time
      t.integer :day
      t.references :employee_listing, foreign_key: true, index: true

      t.timestamps
    end
  end
end
