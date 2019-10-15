class AddNotAvailableToListingAvailability < ActiveRecord::Migration[5.2]
  def change
    add_column :listing_availabilities, :not_available, :boolean, default: false
  end
end
