# == Schema Information
#
# Table name: listing_availabilities
#
#  id                  :bigint           not null, primary key
#  day                 :integer
#  end_time            :time
#  not_available       :boolean          default(FALSE)
#  start_time          :time
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  employee_listing_id :bigint
#
# Indexes
#
#  index_listing_availabilities_on_employee_listing_id  (employee_listing_id)
#
# Foreign Keys
#
#  fk_rails_...  (employee_listing_id => employee_listings.id)
#

require 'test_helper'

class ListingAvailabilityTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
