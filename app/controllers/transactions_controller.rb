class TransactionsController < ApplicationController
  include EmployeeListingsHelper

  before_action :authenticate_user!
  before_action :ensure_company_owner, except: [:check_slot_availability]
  before_action :find_transaction, only: [:initialized, :payment, :request_sent_successfully]
  before_action :ensure_not_poster, only: [:create, :initialized, :payment]
  before_action :find_company, only: [:initialized, :payment]

  def create
    listing = EmployeeListing.find(params[:transaction][:employee_listing_id])

    transactions = listing
                    .transactions
                    .where(state: "accepted")
                    .where("start_date BETWEEN ? AND ? OR end_date BETWEEN ? AND ?",
                      params[:transaction][:start_date], params[:transaction][:end_date],
                      params[:transaction][:start_date], params[:transaction][:end_date])

    transaction_ids = transactions.pluck(:id)
    bookings = Booking.where(transaction_id: transaction_ids).group_by(&:day)
    booked_timings = unavailable_time_slots(bookings)
    requested_booking_slot = params[:transaction][:booking_attributes].to_unsafe_hash
    continue = true

    availability_slots = ListingAvailability::TIME_SLOTS

    requested_booking_slot.each do |booking_day, booking_value|
      if booked_timings[:start_time_slots][booking_day.to_i].present? && booked_timings[:end_time_slots][booking_day.to_i].present?
        if (booked_timings[:start_time_slots][booking_day.to_i] & availability_slots[(availability_slots.index(booking_value["start_time"]))...availability_slots.index(booking_value["end_time"])]).present? || (booked_timings[:end_time_slots][booking_day.to_i] & availability_slots[(availability_slots.index(booking_value["start_time"])+1)..availability_slots.index(booking_value["end_time"])]).present?
          continue = false
          break
        end
      end
    end

    if continue
      transaction = TransactionService.new(params, current_user).create
      if transaction.present?

        # week_day_bookings = transaction.week_day_bookings
        # weekday_hours = 0
        # week_day_bookings.each do |booking|
        #   weekday_hours = weekday_hours + availability_slots[(availability_slots.index(booking.start_time.strftime("%H:%M")))...(availability_slots.index(booking.end_time.strftime("%H:%M")))].count
        # end

        # week_end_bookings = transaction.week_end_bookings
        # weekend_hours = 0
        # week_end_bookings.each do |booking|
        #   weekend_hours = weekend_hours + availability_slots[(availability_slots.index(booking.start_time.strftime("%H:%M")))...(availability_slots.index(booking.end_time.strftime("%H:%M")))].count
        # end

        # week_day_earning = weekday_hours * transaction.employee_listing.weekday_price
        # week_end_earning = weekend_hours * transaction.employee_listing.weekend_price
        # total_weekly_earning = week_day_earning + week_end_earning

        redirect_to initialized_transaction_path(id: transaction.id)
      else
        flash[:error] = "Please check your selected dates and slotes and try again"
        redirect_to employee_path(id: params[:transaction][:employee_listing_id])
      end
    else
      flash[:error] = "Your booking is conflicting from other bookings. Please select different timings"
      redirect_to employee_path(id: params[:transaction][:employee_listing_id])
    end
  end

  def initialized
    @employee_listing = @transaction.employee_listing
    unless request.patch?
      @slot = ""
      all_bookings = @transaction.bookings
      ListingAvailability::DAYS.map{|k,v| v}.each do |day|
        booking = all_bookings.find_by(day: day)
        if booking.present?
          @slot = @slot + Transaction::DAYS_HASH[:"#{day.downcase}"] + " #{booking.start_time.strftime("%H:%M")} - #{booking.end_time.strftime("%H:%M")}, "
        end
      end
    else
      @company.update(company_params)
      @transaction.update_attribute(:probationary_period, params[:transaction][:probationary_period])
      if Conversation.between(current_user.id, @employee_listing.poster.id, @employee_listing.id).present?
        @conversation = Conversation.between(current_user.id, @employee_listing.poster.id, @employee_listing.id).first
      else
        @conversation = Conversation.create!( receiver_id: @employee_listing.poster.id,
                                              sender_id: current_user.id,
                                              employee_listing_id: @employee_listing.id
                                            )
      end
      message = @conversation.messages.build
      message.content = params[:message_text]
      message.sender_id = current_user.id
      message.save
      redirect_to payment_transaction_path(id: @transaction.id)
    end
  end

  def payment
    @employee_listing = @transaction.employee_listing
    unless request.patch?
      @slot = ""
      all_bookings = @transaction.bookings
      ListingAvailability::DAYS.map{|k,v| v}.each do |day|
        booking = all_bookings.find_by(day: day)
        if booking.present?
          @slot = @slot + Transaction::DAYS_HASH[:"#{day.downcase}"] + " #{booking.start_time.strftime("%H:%M")} - #{booking.end_time.strftime("%H:%M")}, "
        end
      end
    else
      # Payment code here
      @transaction.update_attribute(:state, "created")
      TransactionMailer.request_to_hire_email_to_hirer(@transaction, @employee_listing, current_user).deliver!
      TransactionMailer.request_to_hire_email_to_poster(@transaction, @employee_listing, @employee_listing.poster, current_user).deliver!

      redirect_to request_sent_successfully_transaction_path(id: @transaction.id)
    end
  end

  def request_sent_successfully
    @employee_listing = @transaction.employee_listing
  end

  def check_slot_availability
    @employee_listing = EmployeeListing.find(params[:listing_id])
    @start_date = params[:start].to_date
    @end_date = params[:end].to_date

    transactions = @employee_listing
                    .transactions
                    .where(state: "accepted")
                    .where("start_date BETWEEN ? AND ? OR end_date BETWEEN ? AND ?", @start_date, @end_date, @start_date, @end_date)

    transaction_ids = transactions.pluck(:id)
    bookings = Booking.where(transaction_id: transaction_ids).group_by(&:day)
    @disabled_time = unavailable_time_slots(bookings)
    @transaction = @employee_listing.transactions.build
  end

  private

  def company_params
    params.require(:company).permit(
      :name,
      :acn,
      :address_1,
      :address_2,
      :city,
      :state,
      :post_code,
      :country,
      :contact_no
    )
  end

  def find_company
    @company = current_user.company
  end

  def find_transaction
    @transaction = Transaction.find(params[:id])
  end

  def ensure_company_owner
    unless current_user.is_owner? || current_user.is_hr?
      flash[:error] = "You are not authorised to hire an employee"
      redirect_to employee_index_path
    end
  end

  def ensure_not_poster
    if params[:transaction].present? && params[:transaction][:employee_listing_id].present?
      employee_listing = EmployeeListing.find_by(id: params[:transaction][:employee_listing_id])
    elsif params[:id].present?
      employee_listing = Transaction.find_by(id: params[:id]).employee_listing
    else
      flash[:error] = "Invalid request"
      redirect_to employee_index_path
    end

    if employee_listing.present?
      if current_user == employee_listing.poster
        flash[:error] = "Invalid request"
        redirect_to employee_index_path
      end
    else
      flash[:error] = "Invalid request"
      redirect_to employee_index_path
    end
  end
end
