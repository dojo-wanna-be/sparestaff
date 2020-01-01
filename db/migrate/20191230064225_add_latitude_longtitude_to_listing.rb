class AddLatitudeLongtitudeToListing < ActiveRecord::Migration[5.2]
  def change
  	add_column :employee_listings, :latitude, :float
    add_column :employee_listings, :longitude, :float
  end
end
