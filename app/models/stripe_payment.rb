# == Schema Information
#
# Table name: stripe_payments
#
#  id                 :bigint           not null, primary key
#  amount             :float            default(0.0)
#  capture            :boolean          default(FALSE)
#  poster_service_fee :float            default(0.0)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  stripe_charge_id   :string
#  transaction_id     :bigint
#
# Indexes
#
#  index_stripe_payments_on_transaction_id  (transaction_id)
#
# Foreign Keys
#
#  fk_rails_...  (transaction_id => transactions.id)
#

class StripePayment < ApplicationRecord
	belongs_to :listing_transaction, class_name: "Transaction", foreign_key: "transaction_id"
end
