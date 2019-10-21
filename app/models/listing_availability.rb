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

class ListingAvailability < ApplicationRecord
  belongs_to :employee_listing
  enum day: { sunday: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6 }

  DAYS = [["Sunday", "sunday"], ["Monday", "monday"], ["Tuesday", "tuesday"], ["Wednesday", "wednesday"],
          ["Thursday", "thursday"], ["Friday", "friday"], ["Saturday", "saturday"]]

  START_TIME_SLOTS = ["00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00", "07:00", "08:00", "09:00", "10:00", "11:00",
                "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00"]

  END_TIME_SLOTS = ["01:00", "02:00", "03:00", "04:00", "05:00", "06:00", "07:00", "08:00", "09:00", "10:00", "11:00", "12:00",
                "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00", "24:00"]

end
