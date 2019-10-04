class AddAvailabilityFieldsToEmployeeListings < ActiveRecord::Migration[5.2]
  def change
    add_column :employee_listings, :available_in_holidays, :boolean, default: false
    add_column :employee_listings, :weekday_price, :decimal
    add_column :employee_listings, :holiday_price, :decimal
    add_column :employee_listings, :minimum_working_hours, :integer
    add_column :employee_listings, :start_publish_date, :date
    add_column :employee_listings, :end_publish_date, :date
  end
end
