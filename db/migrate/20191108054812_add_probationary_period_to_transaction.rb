class AddProbationaryPeriodToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :probationary_period, :integer
    remove_column :companies, :probationary_period, :integer
  end
end
