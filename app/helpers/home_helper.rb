module HomeHelper
  def checked_parent(classification_id)
    if params[:parent].present?
      params[:parent].include?(classification_id.to_s) ? true : false
    else
      false
    end
  end

  def checked_child(classification_id)
    if params[:child].present?
      params[:child].include?(classification_id.to_s) ? true : false
    else
      false
    end
  end

  def distance_form_search(listing_id)
    listing = EmployeeListing.find_by(id: listing_id)
    location_1 = [listing.latitude, listing.longitude]
    from_location_lat = params[:latitude]
    from_location_long = params[:longitude]
    from_listing_location = [from_location_lat, from_location_long]
    distance = Geocoder::Calculations.distance_between(from_listing_location, location_1)
    distance_in_km = distance * 1.61
    distance_in_km
  end
end
