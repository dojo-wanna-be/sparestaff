class AddFieldToTransaction < ActiveRecord::Migration[5.2]
  def change
  	add_column :transactions, :request_by, :string
  end
end
