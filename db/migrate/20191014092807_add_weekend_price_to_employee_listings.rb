class AddWeekendPriceToEmployeeListings < ActiveRecord::Migration[5.2]
  def change
    add_column :employee_listings, :weekend_price, :decimal
  end
end
