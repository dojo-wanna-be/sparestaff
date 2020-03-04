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

require 'test_helper'

class BookingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
