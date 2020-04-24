class AddExpiryDateToCoupons < ActiveRecord::Migration[5.2]
  def change
    add_column :coupons, :expiry_date, :date
  end
end
