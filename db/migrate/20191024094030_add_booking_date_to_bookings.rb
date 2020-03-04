class AddBookingDateToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :booking_date, :date
  end
end
