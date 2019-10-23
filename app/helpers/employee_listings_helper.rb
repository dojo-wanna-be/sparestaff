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

  def start_time_range(availability)
    start_time = availability.start_time.strftime("%H:%M")
    end_time = availability.end_time.strftime("%H:%M")
    availability_slots = ListingAvailability::TIME_SLOTS
    availability_slots[(availability_slots.index(start_time))..availability_slots.index(end_time)-1]
  end

  def end_time_range(availability)
    start_time = availability.start_time.strftime("%H:%M")
    end_time = availability.end_time.strftime("%H:%M")
    availability_slots = ListingAvailability::TIME_SLOTS
    availability_slots[(availability_slots.index(start_time)+1)..availability_slots.index(end_time)]
  end

  def disable(listing, day)
    if listing.listing_availabilities.present?
      listing.listing_availabilities.pluck(:day).include?(day.downcase) ? "" : "disabled"
    else
      ''
    end
  end

  def listing_images(listing)
    image_urls = []
    image_urls << listing.profile_picture.url if listing.profile_picture.present?
    if listing.relevant_documents.present?
      listing.relevant_documents.each do |relevant_document|
        image_urls << relevant_document.document.url
      end
    end
    return image_urls
  end

  def minimum_price(listing)
    prices = []
    prices << listing.weekday_price if listing.weekday_price.present?
    prices << listing.holiday_price if listing.holiday_price.present?
    prices << listing.weekend_price if listing.weekend_price.present?
    return prices.min
  end
end
