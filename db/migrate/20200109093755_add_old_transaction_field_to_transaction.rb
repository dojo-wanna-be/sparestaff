class AddOldTransactionFieldToTransaction < ActiveRecord::Migration[5.2]
  def change
  	add_column :transactions, :old_transaction, :integer
  end
end
