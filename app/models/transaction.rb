# == Schema Information
#
# Table name: transactions
#
#  id                     :bigint           not null, primary key
#  amount                 :float
#  end_date               :date
#  frequency              :integer
#  is_withholding_tax     :boolean          default(TRUE)
#  reason                 :integer
#  start_date             :date
#  state                  :integer
#  status                 :boolean          default(TRUE)
#  tax_withholding_amount :float
#  total_amount           :float
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  customer_id            :string
#  employee_listing_id    :bigint
#  hirer_id               :integer
#  poster_id              :integer
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
  enum state: { initialized: 0, pending: 1, accepted: 3, rejected: 4, cancelled: 5, expired: 6 }

  DAYS_HASH = {sunday: "Sun", monday: "Mon", tuesday: "Tue", wednesday: "Wed", thursday: "Thu", friday: "Fri", saturday: "Sat"}

  def week_day_bookings
    bookings.where("day > 0 AND day < 6").count
  end

  def week_end_bookings
    bookings.where("day = 0 OR day = 6").count
  end

  def no_of_total_weekdays
    no_of_mondays = (self.start_date..self.end_date).group_by(&:wday)[1].count
    no_of_tuesdays = (self.start_date..self.end_date).group_by(&:wday)[2].count
    no_of_wednesdays = (self.start_date..self.end_date).group_by(&:wday)[3].count
    no_of_thursdays = (self.start_date..self.end_date).group_by(&:wday)[4].count
    no_of_fridays = (self.start_date..self.end_date).group_by(&:wday)[5].count

    total_weekdays =  {
                        mondays: no_of_mondays,
                        tuesdays: no_of_tuesdays,
                        wednesdays: no_of_wednesdays,
                        thursdays: no_of_thursdays,
                        fridays: no_of_fridays
                      }
  end

  def no_of_total_weekends
    no_of_sundays = (self.start_date..self.end_date).group_by(&:wday)[0].count
    no_of_saturdays = (self.start_date..self.end_date).group_by(&:wday)[6].count

    total_weekdays =  {
                        sundays: no_of_sundays,
                        saturdays: no_of_saturdays
                      }
  end
end
