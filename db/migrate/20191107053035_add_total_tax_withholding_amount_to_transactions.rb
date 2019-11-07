class AddTotalTaxWithholdingAmountToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :total_tax_withholding_amount, :float, default: 0
  end
end
