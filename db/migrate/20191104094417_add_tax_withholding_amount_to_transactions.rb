class AddTaxWithholdingAmountToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :tax_withholding_amount, :float
  end
end
