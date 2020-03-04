class AddReasonToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :reason, :text
  end
end
