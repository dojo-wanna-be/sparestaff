class AddPriceToTransactionTable < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :weekday_price, :float, default: 0
    add_column :transactions, :weekend_price, :float, default: 0
    add_column :transactions, :holiday_price, :float, default: 0
  end
end
