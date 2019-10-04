# == Schema Information
#
# Table name: listing_availabilities
#
#  id                  :bigint           not null, primary key
#  start_time          :time
#  end_time            :time
#  day                 :integer
#  employee_listing_id :bigint
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require 'test_helper'

class ListingAvailabilityTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
