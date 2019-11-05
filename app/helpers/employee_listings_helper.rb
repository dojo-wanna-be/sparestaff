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

  def unavailable_time_slots(bookings)
    availability_slots = ListingAvailability::TIME_SLOTS

    sunday_start_bookings = []
    if bookings["sunday"].present?
      bookings["sunday"].each do |sunday_booking|
        sunday_start_bookings << availability_slots[(availability_slots.index(sunday_booking.start_time.strftime("%H:%M")))...availability_slots.index(sunday_booking.end_time.strftime("%H:%M"))]
      end
      sunday_start_bookings = sunday_start_bookings.flatten.uniq
    end
    
    monday_start_bookings = []
    if bookings["monday"].present?
      bookings["monday"].each do |monday_booking|
        monday_start_bookings << availability_slots[(availability_slots.index(monday_booking.start_time.strftime("%H:%M")))...availability_slots.index(monday_booking.end_time.strftime("%H:%M"))]
      end
      monday_start_bookings = monday_start_bookings.flatten.uniq
    end
    
    tuesday_start_bookings = []
    if bookings["tuesday"].present?
      bookings["tuesday"].each do |tuesday_booking|
        tuesday_start_bookings << availability_slots[(availability_slots.index(tuesday_booking.start_time.strftime("%H:%M")))...availability_slots.index(tuesday_booking.end_time.strftime("%H:%M"))]
      end
      tuesday_start_bookings = tuesday_start_bookings.flatten.uniq
    end
    
    wednesday_start_bookings = []
    if bookings["wednesday"].present?
      bookings["wednesday"].each do |wednesday_booking|
        wednesday_start_bookings << availability_slots[(availability_slots.index(wednesday_booking.start_time.strftime("%H:%M")))...availability_slots.index(wednesday_booking.end_time.strftime("%H:%M"))]
      end
      wednesday_start_bookings = wednesday_start_bookings.flatten.uniq
    end
    
    thursday_start_bookings = []
    if bookings["thursday"].present?
      bookings["thursday"].each do |thursday_booking|
        thursday_start_bookings << availability_slots[(availability_slots.index(thursday_booking.start_time.strftime("%H:%M")))...availability_slots.index(thursday_booking.end_time.strftime("%H:%M"))]
      end
      thursday_start_bookings = thursday_start_bookings.flatten.uniq
    end
    
    friday_start_bookings = []
    if bookings["friday"].present?
      bookings["friday"].each do |friday_booking|
        friday_start_bookings << availability_slots[(availability_slots.index(friday_booking.start_time.strftime("%H:%M")))...availability_slots.index(friday_booking.end_time.strftime("%H:%M"))]
      end
      friday_start_bookings = friday_start_bookings.flatten.uniq
    end
    
    saturday_start_bookings = []
    if bookings["saturday"].present?
      bookings["saturday"].each do |saturday_booking|
        saturday_start_bookings << availability_slots[(availability_slots.index(saturday_booking.start_time.strftime("%H:%M")))...availability_slots.index(saturday_booking.end_time.strftime("%H:%M"))]
      end
      saturday_start_bookings = saturday_start_bookings.flatten.uniq
    end

    sunday_end_bookings = []
    if bookings["sunday"].present?
      bookings["sunday"].each do |sunday_booking|
        slot = availability_slots[(availability_slots.index(sunday_booking.start_time.strftime("%H:%M")))..availability_slots.index(sunday_booking.end_time.strftime("%H:%M"))]
        slot.shift
        sunday_end_bookings << slot
      end
      sunday_end_bookings = sunday_end_bookings.flatten.uniq
    end
    
    monday_end_bookings = []
    if bookings["monday"].present?
      bookings["monday"].each do |monday_booking|
        slot = availability_slots[(availability_slots.index(monday_booking.start_time.strftime("%H:%M")))..availability_slots.index(monday_booking.end_time.strftime("%H:%M"))]
        slot.shift
        monday_end_bookings << slot
      end
      monday_end_bookings = monday_end_bookings.flatten.uniq
    end
    
    tuesday_end_bookings = []
    if bookings["tuesday"].present?
      bookings["tuesday"].each do |tuesday_booking|
        slot = availability_slots[(availability_slots.index(tuesday_booking.start_time.strftime("%H:%M")))..availability_slots.index(tuesday_booking.end_time.strftime("%H:%M"))]
        slot.shift
        tuesday_end_bookings << slot
      end
      tuesday_end_bookings = tuesday_end_bookings.flatten.uniq
    end
    
    wednesday_end_bookings = []
    if bookings["wednesday"].present?
      bookings["wednesday"].each do |wednesday_booking|
        slot = availability_slots[(availability_slots.index(wednesday_booking.start_time.strftime("%H:%M")))..availability_slots.index(wednesday_booking.end_time.strftime("%H:%M"))]
        slot.shift
        wednesday_end_bookings << slot
      end
      wednesday_end_bookings = wednesday_end_bookings.flatten.uniq
    end
    
    thursday_end_bookings = []
    if bookings["thursday"].present?
      bookings["thursday"].each do |thursday_booking|
        slot = availability_slots[(availability_slots.index(thursday_booking.start_time.strftime("%H:%M")))..availability_slots.index(thursday_booking.end_time.strftime("%H:%M"))]
        slot.shift
        thursday_end_bookings << slot
      end
      thursday_end_bookings = thursday_end_bookings.flatten.uniq
    end
    
    friday_end_bookings = []
    if bookings["friday"].present?
      bookings["friday"].each do |friday_booking|
        slot = availability_slots[(availability_slots.index(friday_booking.start_time.strftime("%H:%M")))..availability_slots.index(friday_booking.end_time.strftime("%H:%M"))]
        slot.shift
        friday_end_bookings << slot
      end
      friday_end_bookings = friday_end_bookings.flatten.uniq
    end
    
    saturday_end_bookings = []
    if bookings["saturday"].present?
      bookings["saturday"].each do |saturday_booking|
        slot = availability_slots[(availability_slots.index(saturday_booking.start_time.strftime("%H:%M")))..availability_slots.index(saturday_booking.end_time.strftime("%H:%M"))]
        slot.shift
        saturday_end_bookings << slot
      end
      saturday_end_bookings = saturday_end_bookings.flatten.uniq
    end

    # sunday_start_bookings = bookings["sunday"].present? ? bookings["sunday"].map{|booking| booking.start_time.strftime("%H:%M")} : []
    # sunday_end_bookings = bookings["sunday"].present? ? bookings["sunday"].map{|booking| booking.end_time.strftime("%H:%M")} : []
    # monday_start_bookings = bookings["monday"].present? ? bookings["monday"].map{|booking| booking.start_time.strftime("%H:%M")} : []
    # monday_end_bookings = bookings["monday"].present? ? bookings["monday"].map{|booking| booking.end_time.strftime("%H:%M")} : []
    # tuesday_start_bookings = bookings["tuesday"].present? ? bookings["tuesday"].map{|booking| booking.start_time.strftime("%H:%M")} : []
    # tuesday_end_bookings = bookings["tuesday"].present? ? bookings["tuesday"].map{|booking| booking.end_time.strftime("%H:%M")} : []
    # wednesday_start_bookings = bookings["wednesday"].present? ? bookings["wednesday"].map{|booking| booking.start_time.strftime("%H:%M")} : []
    # wednesday_end_bookings = bookings["wednesday"].present? ? bookings["wednesday"].map{|booking| booking.end_time.strftime("%H:%M")} : []
    # thursday_start_bookings = bookings["thursday"].present? ? bookings["thursday"].map{|booking| booking.start_time.strftime("%H:%M")} : []
    # thursday_end_bookings = bookings["thursday"].present? ? bookings["thursday"].map{|booking| booking.end_time.strftime("%H:%M")} : []
    # friday_start_bookings = bookings["friday"].present? ? bookings["friday"].map{|booking| booking.start_time.strftime("%H:%M")} : []
    # friday_end_bookings = bookings["friday"].present? ? bookings["friday"].map{|booking| booking.end_time.strftime("%H:%M")} : []
    # saturday_start_bookings = bookings["saturday"].present? ? bookings["saturday"].map{|booking| booking.start_time.strftime("%H:%M")} : []
    # saturday_end_bookings = bookings["saturday"].present? ? bookings["saturday"].map{|booking| booking.end_time.strftime("%H:%M")} : []

    # disabled_sunday_slots = sunday_start_bookings + sunday_end_bookings
    # disabled_monday_slots = monday_start_bookings + monday_end_bookings
    # disabled_tuesday_slots = tuesday_start_bookings + tuesday_end_bookings
    # disabled_wednesday_slots = wednesday_start_bookings + wednesday_end_bookings
    # disabled_thursday_slots = thursday_start_bookings + thursday_end_bookings
    # disabled_friday_slots = friday_start_bookings + friday_end_bookings
    # disabled_saturday_slots = saturday_start_bookings + saturday_end_bookings

    unavailable_time_slots = {
                                start_time_slots: { 0 =>  sunday_start_bookings,
                                                    1 => monday_start_bookings,
                                                    2 => tuesday_start_bookings,
                                                    3 => wednesday_start_bookings,
                                                    4 => thursday_start_bookings,
                                                    5 => friday_start_bookings,
                                                    6 => saturday_start_bookings,
                                                  },
                                end_time_slots:   { 0 =>  sunday_end_bookings,
                                                    1 => monday_end_bookings,
                                                    2 => tuesday_end_bookings,
                                                    3 => wednesday_end_bookings,
                                                    4 => thursday_end_bookings,
                                                    5 => friday_end_bookings,
                                                    6 => saturday_end_bookings,
                                                  }
                              }
  end
end
