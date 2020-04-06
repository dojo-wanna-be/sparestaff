class CreateStripeRefunds < ActiveRecord::Migration[5.2]
  def change
    create_table :stripe_refunds do |t|
      t.integer :transaction_id
      t.float :amount
      t.float :tax_withholding_amount
      t.float :service_fee
      t.string :refund_id
      t.string :status

      t.timestamps
    end
  end
end
