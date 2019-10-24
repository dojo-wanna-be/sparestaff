# == Schema Information
#
# Table name: employee_listing_slots
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  employee_listing_id :bigint
#  slot_id             :bigint
#
# Indexes
#
#  index_employee_listing_slots_on_employee_listing_id  (employee_listing_id)
#  index_employee_listing_slots_on_slot_id              (slot_id)
#
# Foreign Keys
#
#  fk_rails_...  (employee_listing_id => employee_listings.id)
#  fk_rails_...  (slot_id => slots.id)
#

class EmployeeListingSlot < ApplicationRecord
  belongs_to :employee_listing
  belongs_to :slot
end
