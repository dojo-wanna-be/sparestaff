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
      if tx.save
        create_bookings(tx)
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

  # def no_of_total_weekdays(tx)
  #   no_of_mondays = (@start_date..@end_date).group_by(&:wday)[1].count
  #   no_of_tuesdays = (@start_date..@end_date).group_by(&:wday)[2].count
  #   no_of_wednesdays = (@start_date..@end_date).group_by(&:wday)[3].count
  #   no_of_thursdays = (@start_date..@end_date).group_by(&:wday)[4].count
  #   no_of_fridays = (@start_date..@end_date).group_by(&:wday)[5].count
  #   create_bookings(@start_time, @end_time, tx)

  #   total_weekdays = no_of_mondays + no_of_tuesdays + no_of_wednesdays + no_of_thursdays + no_of_fridays
  # end

  # def no_of_total_weekends(tx)
  #   no_of_sundays = (@start_date..@end_date).group_by(&:wday)[0].count
  #   no_of_saturdays = (@start_date..@end_date).group_by(&:wday)[6].count
  #   create_bookings(@start_time, @end_time)

  #   total_weekends = no_of_sundays + no_of_saturdays
  # end

  def create_bookings(tx)
    @params[:transaction][:booking_attributes].to_unsafe_hash.map do |day, booking_timing|
      if booking_timing[:start_time].present? && booking_timing[:end_time].present?
        (@start_date..@end_date).group_by(&:wday)[day.to_i].each do |date|
          Booking.create( transaction_id: tx.id,
                          day: day.to_i,
                          start_time: booking_timing[:start_time],
                          end_time: booking_timing[:end_time],
                          booking_date: date)
        end
      end
    end
  end

  def self.tax_calculation(weekly_earning)
    flag = false
    weekly_earnings = self.order(:weekly_earning).pluck(:weekly_earning)
    weekly_earnings.each do |earning|
      if weekly_earning < earning
        tax_detail = self.find_by(weekly_earning: earning)
        tax_details_hash = {a: tax_detail.a, b: tax_detail.b}
        return tax_details_hash
      end
    end
    tax_details_hash = {a: 0.4700, b: 576.7885}
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
