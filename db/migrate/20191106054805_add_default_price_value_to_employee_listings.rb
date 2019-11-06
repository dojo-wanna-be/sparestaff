class AddDefaultPriceValueToEmployeeListings < ActiveRecord::Migration[5.2]
  def up
    change_column_default :employee_listings, :weekday_price, 0
    change_column_default :employee_listings, :weekend_price, 0
    change_column_default :employee_listings, :holiday_price, 0
  end

  def down
    change_column_default :employee_listings, :weekday_price, nil
    change_column_default :employee_listings, :weekend_price, nil
    change_column_default :employee_listings, :holiday_price, nil
  end
end
