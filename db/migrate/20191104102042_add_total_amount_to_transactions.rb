class AddTotalAmountToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :total_amount, :float
  end
end
