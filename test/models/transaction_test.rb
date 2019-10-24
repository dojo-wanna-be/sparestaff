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

require 'test_helper'

class TransactionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
