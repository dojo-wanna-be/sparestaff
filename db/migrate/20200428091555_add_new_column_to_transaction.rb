class AddNewColumnToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :discount_percent, :float
    add_column :transactions, :discount_coupon, :string
    add_column :transactions, :amount_before_discount, :float
  end
end
