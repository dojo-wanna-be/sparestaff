class RemoveTotalTaxWithholdingAmountFromTransactions < ActiveRecord::Migration[5.2]
  def up
    remove_column :transactions, :total_tax_withholding_amount, :string
    rename_column :transactions, :total_amount, :remaining_amount
  end

  def down
    add_column :transactions, :total_tax_withholding_amount, :string
    rename_column :transactions, :remaining_amount, :total_amount
  end
end
