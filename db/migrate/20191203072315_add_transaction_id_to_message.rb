class AddTransactionIdToMessage < ActiveRecord::Migration[5.2]
  def change
  	add_column :messages, :transaction_id, :integer
  end
end
