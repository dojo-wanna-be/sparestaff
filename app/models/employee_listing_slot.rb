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

class EmployeeListingSlot < ApplicationRecord
  belongs_to :employee_listing
  belongs_to :slot
end
