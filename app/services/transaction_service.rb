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
        total_weekday_hours = weekly_hours[:total_monday_hours] + weekly_hours[:total_tuesday_hours] + weekly_hours[:total_wednesday_hours] + weekly_hours[:total_thursday_hours] + weekly_hours[:total_friday_hours]
        total_weekend_hours_per_week = weekly_hours[:saturday_hours] + weekly_hours[:sunday_hours]
        total_weekend_hours = weekly_hours[:total_saturday_hours] + weekly_hours[:total_sunday_hours]

        number_of_weeks = @start_date.upto(@end_date).count.fdiv(7).ceil

        tx.weekday_hours = total_weekday_hours_per_week
        tx.weekend_hours = total_weekend_hours_per_week

        tx.total_weekday_hours = total_weekday_hours
        tx.total_weekend_hours = total_weekend_hours

        weekdays_price = listing.weekday_price.to_f * total_weekday_hours_per_week
        weekends_price = listing.weekend_price.to_f * total_weekend_hours_per_week

        total_weekdays_price = listing.weekday_price.to_f * total_weekday_hours
        total_weekends_price = listing.weekend_price.to_f * total_weekend_hours

        weekly_earning = weekdays_price + weekends_price
        total_earning = total_weekdays_price + total_weekends_price

        weekly_tax_withholding = @params[:transaction][:tax_withholding_amount].to_i
        total_tax_withholding = number_of_weeks * @params[:transaction][:tax_withholding_amount]

        if tx.frequency.eql?("weekly")
          tx.tax_withholding_amount = weekly_tax_withholding
          tx.amount = weekly_earning - weekly_tax_withholding
          tx.total_tax_withholding_amount = total_tax_withholding
          tx.total_amount = total_earning - total_tax_withholding
        elsif tx.frequency.eql?("fortnight")
          fortnight_tax_withholding = 2 * weekly_tax_withholding
          total_fortnight_tax_withholding = 2 * total_tax_withholding
          tx.tax_withholding_amount = fortnight_tax_withholding
          tx.amount = weekly_earning - fortnight_tax_withholding
          tx.total_tax_withholding_amount = total_fortnight_tax_withholding
          tx.total_amount = total_earning - total_fortnight_tax_withholding
        end

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
          total_thursday_hours
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
