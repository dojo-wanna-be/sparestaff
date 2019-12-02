# == Schema Information
#
# Table name: transactions
#
#  id                       :bigint           not null, primary key
#  amount                   :float
#  cancelled_at             :date
#  cancelled_by             :integer
#  decline_reason_by_poster :text
#  end_date                 :date
#  frequency                :integer
#  hirer_service_fee        :float
#  hirer_total_service_fee  :float
#  is_withholding_tax       :boolean          default(TRUE)
#  poster_service_fee       :float
#  poster_total_service_fee :float
#  probationary_period      :integer
#  reason                   :text
#  remaining_amount         :float
#  start_date               :date
#  state                    :integer
#  status                   :boolean          default(TRUE)
#  tax_withholding_amount   :float
#  total_weekday_hours      :integer          default(0)
#  total_weekend_hours      :integer          default(0)
#  weekday_hours            :integer
#  weekend_hours            :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  customer_id              :string
#  employee_listing_id      :bigint
#  hirer_id                 :integer
#  poster_id                :integer
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
  has_many :stripe_payment
  has_one :address, dependent: :destroy
  enum frequency: { weekly: 0, fortnight: 1 }
  enum state: { initialized: 0, created: 1, accepted: 2, rejected: 3, cancelled: 4, expired: 5, completed: 6 }
  enum cancelled_by: { hirer: 0, poster: 1 }

  HIRER_SERVICE_FEE = 0.03
  POSTER_SERVICE_FEE = 0.1

  PROBATIONARY_PERIOD = {
                          "1 month" => 1,
                          "2 months" => 2,
                          "3 months" => 3,
                          "4 months" => 4,
                          "5 months" => 5,
                          "6 months" => 6
                        }

  HIRING_CANCELLATION_REASON =  [
                                  "I no longer need to hire an employee",
                                  "My date to hire employee changed",
                                  "I made the hiring my mistake",
                                  "I have extenuating circumstance",
                                  "The poster needs to cancel",
                                  "I'm uncomfortable dealing with the poster or the employee",
                                  "The employee underperforms or does not meet my expectation",
                                  "The employee commited an act of serious misconduct",
                                  "Other"
                                ]

  RESERVATION_CANCELLATION_REASON = [
                                      "My listed employee is no longer available",
                                      "I’m looking for a different price or date and time",
                                      "The hirer needs to cancel",
                                      "The employee or I feel uncomfortable with the hirer",
                                      "Other"
                                    ]

  EMPLOYEE_UNAVAILABLE_REASON = [
                                  "I have an emergency",
                                  "The employee is not available on these dates anymore",
                                  "Another hirer is already hiring the employee on these dates"
                                ]

  DECLINE_REASON =  [
                      "My listing doesn't fit the Hirer's needs",
                      "I want a reservation with a different price, contract length, or start date",
                      "I'm uncomfortable with this reservation"
                    ]

  DAYS_HASH = { sunday: "Sun", monday: "Mon", tuesday: "Tue", wednesday: "Wed", thursday: "Thu", friday: "Fri", saturday: "Sat" }

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
    (HIRER_SERVICE_FEE * amount)
  end

  def total_service_fee
    full_week = start_date.upto(end_date).count.fdiv(7).floor
    transaction_remaining_amount = remaining_amount.present? ? remaining_amount : 0
    remaining_price = transaction_remaining_amount - remaining_tax_withholding(transaction_remaining_amount)
    (service_fee * full_week) + (remaining_price * HIRER_SERVICE_FEE)
  end

  def poster_service_fee
    (POSTER_SERVICE_FEE * amount)
  end

  def poster_total_service_fee
    full_week = start_date.upto(end_date).count.fdiv(7).floor
    transaction_remaining_amount = remaining_amount.present? ? remaining_amount : 0
    remaining_price = transaction_remaining_amount - remaining_tax_withholding(transaction_remaining_amount)
    (poster_service_fee * full_week) + (remaining_price * POSTER_SERVICE_FEE)
  end

  def remaining_tax_withholding(amount)
    if is_withholding_tax
      tax_detail = TaxDetail.tax_calculation(amount)
      ((tax_detail[:a] * (amount + 0.99)) - tax_detail[:b]).round
    else
      0
    end
  end

  def total_tax_withholding
    if is_withholding_tax
      full_week = start_date.upto(end_date).count.fdiv(7).floor
      (tax_withholding_amount * full_week) + remaining_tax_withholding(amount)
    else
      0
    end
  end

  def total_amount
    full_week = start_date.upto(end_date).count.fdiv(7).floor
    transaction_remaining_amount = remaining_amount.present? ? remaining_amount : 0
    remaining_price = transaction_remaining_amount - remaining_tax_withholding(transaction_remaining_amount)
    ((amount + service_fee) * full_week) + remaining_price + (HIRER_SERVICE_FEE * remaining_price)
  end

  def poster_total_amount
    full_week = start_date.upto(end_date).count.fdiv(7).floor
    transaction_remaining_amount = remaining_amount.present? ? remaining_amount : 0
    remaining_price = transaction_remaining_amount - remaining_tax_withholding(transaction_remaining_amount)
    ((amount - poster_service_fee) * full_week) + (remaining_price - (POSTER_SERVICE_FEE * remaining_price))
  end

  def get_beginning_day
    Date.today.beginning_of_week(("#{start_date.strftime("%A").downcase}").to_sym)
  end

  def missed_earning
    week_diff = start_date.upto(Date.today).count.fdiv(7).floor
    full_week_payment = (amount - poster_service_fee) * week_diff
    Date.today > start_date ? poster_total_amount - (full_week_payment + partial_hiring_fee) : poster_total_amount
  end

  def partial_hiring_fee
    weekday_hours = 0
    weekend_hours = 0
    bookings.where(booking_date: (get_beginning_day..Date.today).to_a).each do |booking|
      if ["monday", "tuesday", "wednesday", "thursday", "friday"].include?(booking.day)
        weekday_hours += (booking.end_time - booking.start_time)/3600
      elsif ["sunday", "saturday"].include?(booking.day)
        weekend_hours += (booking.end_time - booking.start_time)/3600
      end
    end
    (weekday_hours * employee_listing.weekday_price.to_f) + (weekend_hours * employee_listing.weekend_price.to_f)
  end

  def accepted
    state == 'accepted' ? true : false
  end
end
