namespace :employee_listing do
  desc "TODO"
  task assign_lat_long: :environment do
  	EmployeeListing.all.active.published.each do |el|
			address = [el.address_1, el.address_2, el.city, el.state, el.country, el.post_code].compact.join(', ')
			results = Geocoder.search(address).first.coordinates
			el.update_attributes(latitude: results[0],longitude: results[0])
		end
  end

end
