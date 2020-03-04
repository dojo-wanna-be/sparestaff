class AddCancelledAtToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :cancelled_at, :date
  end
end
