# == Schema Information
#
# Table name: transactions
#
#  id                           :bigint           not null, primary key
#  amount                       :float
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

require 'test_helper'

class TransactionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
