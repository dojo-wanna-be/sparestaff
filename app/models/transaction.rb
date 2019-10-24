# == Schema Information
#
# Table name: transactions
#
#  id                  :bigint           not null, primary key
#  amount              :float
#  end_date            :date
#  frequency           :integer
#  is_withholding_tax  :boolean          default(TRUE)
#  start_date          :date
#  state               :integer
#  status              :boolean          default(TRUE)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  customer_id         :string
#  employee_listing_id :bigint
#  hirer_id            :integer
#  poster_id           :integer
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
  has_many :bookings

  enum frequency: { weekly: 0, fortnight: 1 }
  enum state: { initialized: 0, pending: 1, accepted: 3, rejected: 4, cancelled: 5, expired: 6 }
end
