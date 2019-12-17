class AddAdjustmentFieldToTransaction < ActiveRecord::Migration[5.2]
  def change
  	add_column :transactions, :adjustment, :float
  end
end
