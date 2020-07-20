class CreateStripeRefundReceipts < ActiveRecord::Migration[5.2]
  def change
    create_table :stripe_refund_receipts do |t|
      t.integer :transaction_id
      t.float :amount
      t.float :tax_withholding_amount
      t.float :service_fee

      t.timestamps
    end
  end
end
