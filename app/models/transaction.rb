# == Schema Information
#
# Table name: transactions
#
#  id                           :bigint           not null, primary key
#  amount                       :float
#  cancelled_by                 :integer
#  end_date                     :date
#  frequency                    :integer
#  is_withholding_tax           :boolean          default(TRUE)
#  probationary_period          :integer
#  reason                       :text
#  start_date                   :date
#  state                        :integer
#  status                       :boolean          default(TRUE)
#  tax_withholding_amount       :float
#  total_amount                 :float
#  total_tax_withholding_amount :float            default(0.0)
#  total_weekday_hours          :integer          default(0)
#  total_weekend_hours          :integer          default(0)
#  weekday_hours                :integer
#  weekend_hours                :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  customer_id                  :string
#  employee_listing_id          :bigint
#  hirer_id                     :integer
#  poster_id                    :integer
#
# Indexes
#
#  index_transactions_on_employee_listing_id  (employee_listing_id)
#
# Foreign Keys
#
#  fk_rails_...  (employee_listing_id => employee_listings.id)
#

class Transaction < ApplicationRecord
  belongs_to :employee_listing
  belongs_to :hirer, class_name: "User", foreign_key: "hirer_id"
  belongs_to :poster, class_name: "User", foreign_key: "poster_id"
  has_many :bookings, dependent: :destroy

  enum frequency: { weekly: 0, fortnight: 1 }
  enum state: { initialized: 0, created: 1, accepted: 2, rejected: 3, cancelled: 4, expired: 5, completed: 6 }
  enum cancelled_by: { hirer: 0, poster: 1 }

  SERVICE_FEE = 3

  PROBATIONARY_PERIOD = {
                          "1 month" => 1,
                          "2 months" => 2,
                          "3 months" => 3,
                          "4 months" => 4,
                          "5 months" => 5,
                          "6 months" => 6
                        }

  CANCELLATION_REASON = ["I no longer need to hire an employee",
             "My date to hire employee changed",
             "I made the hiring my mistake",
             "I have extenuating circumstance",
             "The poster needs to cancel",
             "I'm uncomfortable dealing with the poster or the employee",
             "The employee underperforms or does not meet my expectation",
             "The employee commited an act of serious misconduct",
             "Other"]

  DAYS_HASH = {sunday: "Sun", monday: "Mon", tuesday: "Tue", wednesday: "Wed", thursday: "Thu", friday: "Fri", saturday: "Sat"}

  def week_day_bookings
    bookings.where("day > 0 AND day < 6").count
  end

  def week_end_bookings
    bookings.where("day = 0 OR day = 6").count
  end

  def total_days(day)
    no_of_mondays = (self.start_date..self.end_date).group_by(&:wday)[day].count
  end

  def no_of_total_weekdays
    total_weekdays =  {
                        mondays: total_days(1),
                        tuesdays: total_days(2),
                        wednesdays: total_days(3),
                        thursdays: total_days(4),
                        fridays: total_days(5)
                      }
  end

  def no_of_total_weekends
    total_weekdays =  {
                        sundays: total_days(0),
                        saturdays: total_days(6)
                      }
  end

  def service_fee
    (0.03 * amount)
  end

  def total_service_fee
    (0.03 * total_amount)
  end

  def partial_hiring_fee
    week_start_date = Date.today.beginning_of_week(("#{start_date.strftime("%A").downcase}").to_sym)
    todays_date = Date.today
    weekday_slots = []
    weekend_slots = []
    availability_slots = ListingAvailability::TIME_SLOTS
    all_bookings = bookings.where(booking_date: (week_start_date..todays_date).to_a)
    all_bookings.each do |booking|
      if ["monday", "tuesday", "wednesday", "thursday", "friday"].include?(booking.day)
        weekday_slots << availability_slots[availability_slots.index(booking.start_time.strftime("%H:%M"))...availability_slots.index(booking.end_time.strftime("%H:%M"))]
      elsif ["sunday", "saturday"].include?(booking.day)
        weekend_slots << availability_slots[availability_slots.index(booking.start_time.strftime("%H:%M"))...availability_slots.index(booking.end_time.strftime("%H:%M"))]
      end
    end
    weekday_hours = weekday_slots.flatten.uniq.count
    weekend_hours = weekend_slots.flatten.uniq.count
    weekday_price = self.employee_listing.weekday_price.to_f
    weekend_price = self.employee_listing.weekend_price.to_f
    (weekday_hours * weekday_price) + (weekend_hours * weekend_price)
  end
end
