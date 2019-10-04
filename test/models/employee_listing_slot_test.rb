# == Schema Information
#
# Table name: employee_listing_slots
#
#  id                  :bigint           not null, primary key
#  slot_id             :bigint
#  employee_listing_id :bigint
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require 'test_helper'

class EmployeeListingSlotTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
