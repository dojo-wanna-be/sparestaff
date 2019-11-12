class AddCancelledByToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :cancelled_by, :integer
  end
end
