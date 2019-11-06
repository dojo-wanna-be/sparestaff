class AddHoursToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :weekday_hours, :integer
    add_column :transactions, :weekend_hours, :integer
  end
end
