class AddTransactionIdToConversation < ActiveRecord::Migration[5.2]
  def change
  	add_column :conversations, :transaction_id, :integer
  end
end
