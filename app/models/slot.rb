# == Schema Information
#
# Table name: slots
#
#  id         :bigint           not null, primary key
#  time_slot  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Slot < ApplicationRecord
  has_many :employee_listing_slots
  has_many :employee_listings, through: :employee_listing_slots
end
