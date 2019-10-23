class CreateBookings < ActiveRecord::Migration[5.2]
  def change
    create_table :bookings do |t|
      t.integer :day
      t.time :start_time
      t.time :end_time
      t.references :transaction, foreign_key: true, index: true

      t.timestamps
    end
  end
end
