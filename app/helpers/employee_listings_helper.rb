module EmployeeListingsHelper
  def languages_present(object, global_language)
    object.languages.pluck(:id).include?(global_language.id)
  end

  def selected_start_time(listing, day)
    availability = listing.listing_availabilities.find_by(day: day)
    availability.present? && availability.start_time.present? ? availability.start_time.strftime("%H:%M") : ""
  end

  def selected_end_time(listing, day)
    availability = listing.listing_availabilities.find_by(day: day)
    availability.present? && availability.end_time.present? ? availability.end_time.strftime("%H:%M") : ""
  end

  def disable(listing, day)
    if listing.listing_availabilities.present?
      listing.listing_availabilities.pluck(:day).include?(day.downcase) ? "" : "disabled"
    else
      ''
    end
  end
end
