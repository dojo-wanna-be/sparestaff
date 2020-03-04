class AddNextTransactionFieldToTransaction < ActiveRecord::Migration[5.2]
  def change
  	add_column :transactions, :next_payment, :date
  end
end
