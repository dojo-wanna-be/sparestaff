class AddTotalHoursToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :total_weekday_hours, :integer, default: 0
    add_column :transactions, :total_weekend_hours, :integer, default: 0
  end
end
