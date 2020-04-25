namespace :employee_listing do
  desc "Creating notification_setting for users"
  task update_star_rating: :environment do
    EmployeeListing.all.each do |u|
      u.update(rating_count: ApplicationController.helpers.listing_star_rating(u.id))
    end
  end
end