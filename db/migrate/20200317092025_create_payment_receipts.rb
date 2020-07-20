class CreatePaymentReceipts < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_receipts do |t|
      t.date :start_date
      t.date :end_date
      t.float :tx_price
      t.belongs_to :transaction, foreign_key: true, index: true

      t.timestamps
    end
  end
end
