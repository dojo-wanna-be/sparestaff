class RemoveColumnNextPaymentTransaction < ActiveRecord::Migration[5.2]
  def change
  	remove_column :transactions, :next_payment, :date
  end
end
