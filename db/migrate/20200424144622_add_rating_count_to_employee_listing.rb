class AddRatingCountToEmployeeListing < ActiveRecord::Migration[5.2]
  def change
  	add_column :employee_listings, :rating_count, :float
  end
end
