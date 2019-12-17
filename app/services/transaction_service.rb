class TransactionService
  def initialize(params, hirer)
    @params = params
    @hirer = hirer
    @start_date = params[:transaction][:start_date].to_date
    @end_date = params[:transaction][:end_date].to_date
  end

  def create
    ActiveRecord::Base.transaction do
      tx = Transaction.new(transaction_params)
      listing = tx.employee_listing
      tx.hirer_id = @hirer.id
      tx.poster_id = listing.poster.id
      tx.state = "initialized"
      availability_slots = ListingAvailability::TIME_SLOTS

      if tx.save
        weekly_hours = create_bookings(tx, availability_slots)
        total_weekday_hours_per_week = weekly_hours[:monday_hours] + weekly_hours[:tuesday_hours] + weekly_hours[:wednesday_hours] + weekly_hours[:thursday_hours] + weekly_hours[:friday_hours]
        total_weekend_hours_per_week = weekly_hours[:saturday_hours] + weekly_hours[:sunday_hours]
        weekdays_price = listing.weekday_price.to_f * total_weekday_hours_per_week
        weekends_price = listing.weekend_price.to_f * total_weekend_hours_per_week
        weekly_earning = weekdays_price + weekends_price

        total_weekday_hours = weekly_hours[:total_monday_hours] + weekly_hours[:total_tuesday_hours] + weekly_hours[:total_wednesday_hours] + weekly_hours[:total_thursday_hours] + weekly_hours[:total_friday_hours]
        total_weekend_hours = weekly_hours[:total_saturday_hours] + weekly_hours[:total_sunday_hours]

        week_diff = @start_date.upto(@end_date).count.fdiv(7).floor
        monday = 0
        tuesday = 0
        wednesday = 0
        thursday = 0
        friday = 0
        saturday = 0
        sunday = 0
        if weekly_hours[:no_of_mondays] > 0
          monday = weekly_hours[:no_of_mondays] - week_diff
        end
        if weekly_hours[:no_of_tuesdays] > 0
          tuesday = weekly_hours[:no_of_tuesdays] - week_diff
        end
        if weekly_hours[:no_of_wednesdays] > 0
          wednesday = weekly_hours[:no_of_wednesdays] - week_diff
        end
        if weekly_hours[:no_of_thursdays] > 0
          thursday = weekly_hours[:no_of_thursdays] - week_diff
        end
        if weekly_hours[:no_of_fridays] > 0
          friday = weekly_hours[:no_of_fridays] - week_diff
        end
        if weekly_hours[:no_of_saturdays] > 0
          saturday = weekly_hours[:no_of_saturdays] - week_diff
        end
        if weekly_hours[:no_of_sundays] > 0
          sunday = weekly_hours[:no_of_sundays] - week_diff
        end
        remaining_weekday_price =  (monday * weekly_hours[:monday_hours] + tuesday * weekly_hours[:tuesday_hours] + wednesday * weekly_hours[:wednesday_hours] + thursday * weekly_hours[:thursday_hours] + friday * weekly_hours[:friday_hours]) * listing.weekday_price.to_f

        remaining_weekend_price = (saturday * weekly_hours[:saturday_hours] + sunday * weekly_hours[:sunday_hours]) * listing.weekend_price.to_f

        remaining_weekly_earning = remaining_weekday_price + remaining_weekend_price
        weekly_tax_withholding = if tx.is_withholding_tax
          @params[:transaction][:tax_withholding_amount].to_i.abs
        else
          0
        end
        tx.remaining_amount = remaining_weekly_earning
        tx.weekday_hours = total_weekday_hours_per_week
        tx.weekend_hours = total_weekend_hours_per_week
        tx.total_weekday_hours = total_weekday_hours
        tx.total_weekend_hours = total_weekend_hours
        tx.tax_withholding_amount = weekly_tax_withholding
        tx.amount = weekly_earning
        tx.adjustment = @params[:adjustment_amount] if @params[:adjustment_amount].present?
        tx.save
        return tx
      else
        ActiveRecord::RollBack
        return nil
      end
    end
    rescue Exception => e
      return nil
  end

  private

  def create_bookings(tx, availability_slots)
    sunday_hours = 0
    monday_hours = 0
    tuesday_hours = 0
    wednesday_hours = 0
    thursday_hours = 0
    friday_hours = 0
    saturday_hours = 0
    no_of_sundays = 0
    no_of_mondays = 0
    no_of_tuesdays = 0
    no_of_wednesdays = 0
    no_of_thursdays = 0
    no_of_fridays = 0
    no_of_saturdays = 0
    total_sunday_hours = 0
    total_monday_hours = 0
    total_tuesday_hours = 0
    total_wednesday_hours = 0
    total_thursday_hours = 0
    total_friday_hours = 0
    total_saturday_hours = 0

    @params[:transaction][:booking_attributes].to_unsafe_hash.map do |day, booking_timing|
      if day.eql?("0")
        if booking_timing[:start_time].present? && booking_timing[:end_time].present? && (@start_date..@end_date).group_by(&:wday)[day.to_i].present?
          (@start_date..@end_date).group_by(&:wday)[day.to_i].each do |date|
            Booking.create( transaction_id: tx.id,
                            day: day.to_i,
                            start_time: booking_timing[:start_time],
                            end_time: booking_timing[:end_time],
                            booking_date: date)
          end
          sunday_hours = availability_slots[availability_slots.index(booking_timing[:start_time])...availability_slots.index(booking_timing[:end_time])].count
          no_of_sundays = (tx.start_date..tx.end_date).group_by(&:wday)[0].count
          total_sunday_hours = sunday_hours * no_of_sundays
        else
          sunday_hours = 0
          total_sunday_hours = 0
          no_of_sundays = 0
        end
      end

      if day.eql?("1")
        if booking_timing[:start_time].present? && booking_timing[:end_time].present? && (@start_date..@end_date).group_by(&:wday)[day.to_i].present?
          (@start_date..@end_date).group_by(&:wday)[day.to_i].each do |date|
            Booking.create( transaction_id: tx.id,
                            day: day.to_i,
                            start_time: booking_timing[:start_time],
                            end_time: booking_timing[:end_time],
                            booking_date: date)
          end
          monday_hours = availability_slots[availability_slots.index(booking_timing[:start_time])...availability_slots.index(booking_timing[:end_time])].count
          no_of_mondays = (tx.start_date..tx.end_date).group_by(&:wday)[1].count
          total_monday_hours = monday_hours * no_of_mondays
        else
          monday_hours = 0
          total_monday_hours = 0
          no_of_mondays = 0
        end
      end

      if day.eql?("2")
        if booking_timing[:start_time].present? && booking_timing[:end_time].present? && (@start_date..@end_date).group_by(&:wday)[day.to_i].present?
          (@start_date..@end_date).group_by(&:wday)[day.to_i].each do |date|
            Booking.create( transaction_id: tx.id,
                            day: day.to_i,
                            start_time: booking_timing[:start_time],
                            end_time: booking_timing[:end_time],
                            booking_date: date)
          end
          tuesday_hours = availability_slots[availability_slots.index(booking_timing[:start_time])...availability_slots.index(booking_timing[:end_time])].count
          no_of_tuesdays = (tx.start_date..tx.end_date).group_by(&:wday)[2].count
          total_tuesday_hours = tuesday_hours * no_of_tuesdays
        else
          tuesday_hours = 0
          total_tuesday_hours = 0
          no_of_tuesdays = 0
        end
      end

      if day.eql?("3")
        if booking_timing[:start_time].present? && booking_timing[:end_time].present? && (@start_date..@end_date).group_by(&:wday)[day.to_i].present?
          (@start_date..@end_date).group_by(&:wday)[day.to_i].each do |date|
            Booking.create( transaction_id: tx.id,
                            day: day.to_i,
                            start_time: booking_timing[:start_time],
                            end_time: booking_timing[:end_time],
                            booking_date: date)
          end
          wednesday_hours = availability_slots[availability_slots.index(booking_timing[:start_time])...availability_slots.index(booking_timing[:end_time])].count
          no_of_wednesdays = (tx.start_date..tx.end_date).group_by(&:wday)[3].count
          total_wednesday_hours = wednesday_hours * no_of_wednesdays
        else
          wednesday_hours = 0
          total_wednesday_hours = 0
          no_of_wednesdays = 0
        end
      end

      if day.eql?("4")
        if booking_timing[:start_time].present? && booking_timing[:end_time].present? && (@start_date..@end_date).group_by(&:wday)[day.to_i].present?
          (@start_date..@end_date).group_by(&:wday)[day.to_i].each do |date|
            Booking.create( transaction_id: tx.id,
                            day: day.to_i,
                            start_time: booking_timing[:start_time],
                            end_time: booking_timing[:end_time],
                            booking_date: date)
          end
          thursday_hours = availability_slots[availability_slots.index(booking_timing[:start_time])...availability_slots.index(booking_timing[:end_time])].count
          no_of_thursdays = (tx.start_date..tx.end_date).group_by(&:wday)[4].count
          total_thursday_hours = thursday_hours * no_of_thursdays
        else
          thursday_hours = 0
          total_thursday_hours = 0
          no_of_thursdays = 0
        end
      end

      if day.eql?("5")
        if booking_timing[:start_time].present? && booking_timing[:end_time].present? && (@start_date..@end_date).group_by(&:wday)[day.to_i].present?
          (@start_date..@end_date).group_by(&:wday)[day.to_i].each do |date|
            Booking.create( transaction_id: tx.id,
                            day: day.to_i,
                            start_time: booking_timing[:start_time],
                            end_time: booking_timing[:end_time],
                            booking_date: date)
          end
          friday_hours = availability_slots[availability_slots.index(booking_timing[:start_time])...availability_slots.index(booking_timing[:end_time])].count
          no_of_fridays = (tx.start_date..tx.end_date).group_by(&:wday)[5].count
          total_friday_hours = friday_hours * no_of_fridays
        else
          friday_hours = 0
          total_friday_hours = 0
          no_of_fridays = 0
        end
      end

      if day.eql?("6")
        if booking_timing[:start_time].present? && booking_timing[:end_time].present? && (@start_date..@end_date).group_by(&:wday)[day.to_i].present?
          (@start_date..@end_date).group_by(&:wday)[day.to_i].each do |date|
            Booking.create( transaction_id: tx.id,
                            day: day.to_i,
                            start_time: booking_timing[:start_time],
                            end_time: booking_timing[:end_time],
                            booking_date: date)
          end
          saturday_hours = availability_slots[availability_slots.index(booking_timing[:start_time])...availability_slots.index(booking_timing[:end_time])].count
          no_of_saturdays = (tx.start_date..tx.end_date).group_by(&:wday)[6].count
          total_saturday_hours = saturday_hours * no_of_saturdays
        else
          saturday_hours = 0
          total_saturday_hours = 0
          no_of_saturdays = 0
        end
      end
    end

    {
      sunday_hours: sunday_hours,
      monday_hours: monday_hours,
      tuesday_hours: tuesday_hours,
      wednesday_hours: wednesday_hours,
      thursday_hours: thursday_hours,
      friday_hours: friday_hours,
      saturday_hours: saturday_hours,
      no_of_sundays: no_of_sundays,
      no_of_mondays: no_of_mondays,
      no_of_tuesdays: no_of_tuesdays,
      no_of_wednesdays: no_of_wednesdays,
      no_of_thursdays: no_of_thursdays,
      no_of_fridays: no_of_fridays,
      no_of_saturdays: no_of_saturdays,
      total_sunday_hours: total_sunday_hours,
      total_monday_hours: total_monday_hours,
      total_tuesday_hours: total_tuesday_hours,
      total_wednesday_hours: total_wednesday_hours,
      total_thursday_hours: total_thursday_hours,
      total_friday_hours: total_friday_hours,
      total_saturday_hours: total_saturday_hours
    }
  end

  def transaction_params
    @params.require(:transaction).except(:booking_attributes).permit(
      :employee_listing_id,
      :frequency,
      :start_date,
      :end_date,
      :is_withholding_tax
    )
  end
end
