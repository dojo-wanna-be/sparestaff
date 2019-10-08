module EmployeeListingsHelper
  def languages_present(object, global_language)
    object.languages.pluck(:id).include?(global_language.id)
  end

  def selected_start_time(listing, day)
    availablity = listing.listing_availabilities.find_by(day: day)
    availablity.present? ? availablity.start_time.strftime("%H:%M") : ""
  end

  def selected_end_time(listing, day)
    availablity = listing.listing_availabilities.find_by(day: day)
    availablity.present? ? availablity.end_time.strftime("%H:%M") : ""
  end
end
