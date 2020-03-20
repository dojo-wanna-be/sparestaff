class PaymentReceipt < ApplicationRecord
  belongs_to :listing_transaction, class_name: "Transaction", foreign_key: "transaction_id"
end
