class AddReasonToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :reason, :integer
  end
end
