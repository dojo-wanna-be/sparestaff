# == Schema Information
#
# Table name: bookings
#
#  id             :bigint           not null, primary key
#  booking_date   :date
#  day            :integer
#  end_time       :time
#  start_time     :time
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  transaction_id :bigint
#
# Indexes
#
#  index_bookings_on_transaction_id  (transaction_id)
#
# Foreign Keys
#
#  fk_rails_...  (transaction_id => transactions.id)
#

class Booking < ApplicationRecord
  belongs_to :listing_transaction, class_name: "Transaction", foreign_key: "transaction_id"

  enum day: { sunday: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6 }
end
