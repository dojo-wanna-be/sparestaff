class ReservationsController < ApplicationController
  include EmployeeListingsHelper

  before_action :ensure_poster, except: [:index]
  skip_before_action :authenticate_user!, only: [:check_slot_availability]
  before_action :find_transaction, only: [
                                          :change_or_cancel,
                                          :change_reservation,
                                          :change_reservation_confirmation,
                                          :changed_successfully,
                                          :cancel_reservation,
                                          :tell_hirer,
                                          :cancelled_successfully,
                                          :show,
                                          :accept,
                                          :decline_request,
                                          :decline,
                                          :reservations_view_invoice_list,
                                          :write_a_review
                                         ]

  def index
    poster_transactions = Transaction.where(poster_id: current_user.id).order(updated_at: :desc)
    @posted_listing_transactions = poster_transactions.where("end_date > ?", Date.today).where(state: [:accepted, :rejected, :created, :cancelled]).includes(:employee_listing)
    @completed_listing_transactions = poster_transactions.where("end_date < ?", Date.today).where(state: [:rejected, :cancelled, :expired, :completed]).includes(:employee_listing)
  end

  def show
    @listing = @transaction.employee_listing
  end

  def change_or_cancel
    @listing = @transaction.employee_listing
  end

  def accept
    if @transaction.update_attributes(state: "accepted")
      @listing = @transaction.employee_listing
      hirer = User.find_by(id: @transaction.hirer_id)
      create_message
      ReservationMailer.employee_hire_confirmation_email_to_poster(@listing, current_user, @transaction).deliver_later!
      ReservationMailer.employee_hire_confirmation_email_to_hirer(@listing, hirer, @transaction).deliver_later!
      redirect_to inbox_path(id: @transaction.conversation.id)
    else
      flash[:error] = "Something went wrong"
      redirect_to inbox_path(id: @transaction.conversation.id)
    end
  end

  def decline_request
    @transaction.update_attribute(:reason, params[:reason])
    create_message
  end

  def decline
    if @transaction.update_attributes(state: "rejected", decline_reason_by_poster: params[:message_text])
      @listing = @transaction.employee_listing
      conversation = Conversation.between(current_user.id, @transaction.hirer_id, @transaction.id)
      message = find_or_create_conversation.messages&.last.present? ? @conversation.messages.last : ""
      ReservationMailer.employee_hire_declined_email_to_Poster(@listing, current_user, @transaction, message).deliver_later!
      ReservationMailer.employee_hire_declined_email_to_Hirer(@listing, @transaction.hirer, @transaction, message).deliver_later!
      redirect_to inbox_path(id: @transaction.conversation.id)
    else
      flash[:error] = "Something went wrong"
      redirect_to inbox_path(id: @transaction.conversation.id)
    end
  end

  # def change_listing_approval
  #   @old_transaction = Transaction.find_by(id: params[:old_id])
  #   @transaction = Transaction.find_by(id: params[:id])

  #   if params[state: "accepted"]
  #     @old_transaction.update_attributes(state: "completed", status: false)

  #     @transaction.update_attribute(:state, "accepted")

        # Transaction changed accepted mail to hirer
  #     redirect_to inbox_path(id: @transaction.conversation.id)
  #   elsif params[state: "rejected"]

  #     @transaction.update_attributes(state: "rejected", status: false)
        # Transaction changed rejected mail to hirer
  #     redirect_to inbox_path(id: @old_transaction.conversation.id)
  #   end
  # end

  def change_reservation
    @old_transaction = @transaction
    @listing = @transaction.employee_listing
    @weekly_hourly_total = (@listing.weekday_price.to_f * @old_transaction.total_weekday_hours + @listing.weekend_price.to_f * @old_transaction.total_weekend_hours)
    @weekly_payout = @weekly_hourly_total - @old_transaction.tax_withholding_amount - @old_transaction.poster_service_fee.round(2)
    unless request.patch?
      @start_date = @transaction.start_date
      @end_date = @transaction.end_date

      transactions = @listing
                    .transactions
                    .where(state: "accepted")
                    .where("start_date BETWEEN ? AND ? OR end_date BETWEEN ? AND ?", @start_date, @end_date, @start_date, @end_date)
                    .where.not(id: @old_transaction.id)

      transaction_ids = transactions.pluck(:id)
      bookings = Booking.where(transaction_id: transaction_ids).group_by(&:day)
      @transaction.bookings.group_by(&:day).each do |day, bookings|
        instance_variable_set "@#{day}Hour".to_sym, (bookings.first.end_time - bookings.first.start_time) / 3600
      end
      @disabled_time = unavailable_time_slots(bookings)
    else
      listing = EmployeeListing.find(params[:transaction][:employee_listing_id])

      transactions = listing
                      .transactions
                      .where(state: "accepted")
                      .where("start_date BETWEEN ? AND ? OR end_date BETWEEN ? AND ?",
                        params[:transaction][:start_date], params[:transaction][:end_date],
                        params[:transaction][:start_date], params[:transaction][:end_date])
                      .where.not(id: @old_transaction.id)

      transaction_ids = transactions.pluck(:id)
      bookings = Booking.where(transaction_id: transaction_ids).group_by(&:day)
      booked_timings = unavailable_time_slots(bookings)
      requested_booking_slot = params[:transaction][:booking_attributes].to_unsafe_hash
      continue = true

      availability_slots = ListingAvailability::TIME_SLOTS

      requested_booking_slot.each do |booking_day, booking_value|
        if booked_timings[:start_time_slots][booking_day.to_i].present? && booked_timings[:end_time_slots][booking_day.to_i].present? && booking_value["start_time"].present? && booking_value["end_time"].present?
          if (booked_timings[:start_time_slots][booking_day.to_i] & availability_slots[(availability_slots.index(booking_value["start_time"]))...availability_slots.index(booking_value["end_time"])]).present? || (booked_timings[:end_time_slots][booking_day.to_i] & availability_slots[(availability_slots.index(booking_value["start_time"])+1)..availability_slots.index(booking_value["end_time"])]).present?
            continue = false
            break
          end
        end
      end

      if continue
        hirer = User.find_by(id: @old_transaction.hirer_id)
        @new_transaction = TransactionService.new(params, hirer).create
        if @new_transaction.present?
          @new_transaction.hirer_service_fee = @new_transaction.service_fee
          @new_transaction.hirer_total_service_fee = @new_transaction.total_service_fee
          @new_transaction.poster_service_fee = @new_transaction.poster_service_fee
          @new_transaction.poster_total_service_fee = @new_transaction.poster_total_service_fee

          @new_transaction.save
          redirect_to change_reservation_confirmation_reservation_path(id: @new_transaction.id, old_id: @old_transaction.id)
        else
          flash[:error] = "Please check your selected dates and slotes and try again"
          redirect_to change_reservation_reservation_path(id: @old_transaction.id)
        end
      else
        flash[:error] = "Your booking is conflicting from other bookings. Please select different timings"
        redirect_to change_reservation_reservation_path(id: @old_transaction.id)
      end
    end
  end

  def change_reservation_confirmation
    @listing = @transaction.employee_listing
    @old_transaction = Transaction.find_by(id: params[:old_id])
    hirer = User.find_by(id: @old_transaction.hirer_id)
    if request.patch?
      @transaction.update_attribute(:state, "created")
      message = find_or_create_conversation.messages.last
      ReservationMailer.reservation_changed_email_to_poster(@listing, current_user, @transaction, message).deliver_later!
      ReservationMailer.reservation_changed_email_to_hirer(@listing, hirer, @transaction).deliver_later!
      redirect_to changed_successfully_reservation_path(id: @transaction.id, old_id: @old_transaction.id)
    end
  end

  def changed_successfully
    @listing = @transaction.employee_listing
    @old_transaction = Transaction.find_by(id: params[:old_id])
  end

  def cancel_reservation
    unless request.patch?
      @listing = @transaction.employee_listing
    else
      @transaction.update_attributes(reason: params[:reason], cancelled_by: "poster")
      redirect_to tell_hirer_reservation_path(id: @transaction.id)
    end
  end

  def tell_hirer
    @listing = @transaction.employee_listing
    if request.patch?
      if params[:reason]
        @transaction.update_attributes(reason: params[:reason], cancelled_by: "poster", state: "cancelled", cancelled_at: Date.today)
      else
        @transaction.update_attributes(state: "cancelled", cancelled_at: Date.today)
      end
      create_message
      TransactionMailer.reservation_cancelled_email_to_poster(@listing, current_user, @transaction).deliver_later!
      TransactionMailer.reservation_cancelled_email_to_hirer(@listing, current_user, @transaction, @transaction.hirer).deliver_later!
      redirect_to cancelled_successfully_reservations_path(id: @transaction.id)
    end
  end

  def cancelled_successfully
    @listing = @transaction.employee_listing
    conversation = Conversation.between(current_user.id, @transaction.hirer_id, @transaction.id)
    if conversation.present?
      @conversation = conversation.first
    end
  end

  def check_slot_availability
    @employee_listing = EmployeeListing.find(params[:listing_id])
    @start_date = params[:start].to_date
    @end_date = params[:end].to_date
    @transaction = Transaction.find(params[:transaction_id])
    transactions = @employee_listing
                    .transactions
                    .where(state: "accepted")
                    .where("start_date BETWEEN ? AND ? OR end_date BETWEEN ? AND ?", @start_date, @end_date, @start_date, @end_date)
                    .where.not(id: @transaction.id)

    transaction_ids = transactions.pluck(:id)
    bookings = Booking.where(transaction_id: transaction_ids).group_by(&:day)
    @transaction.bookings.group_by(&:day).each do |day, bookings|
      instance_variable_set "@#{day}Hour".to_sym, (bookings.first.end_time - bookings.first.start_time) / 3600
    end
    @disabled_time = unavailable_time_slots(bookings)
  end

  def reservations_view_invoice_list
    poster_transactions = Transaction.where(poster_id: current_user.id, state: ["accepted", "rejected", "created"]).order(updated_at: :desc)
    @posted_listing_transactions = poster_transactions.includes(:employee_listing)
    poster_completed_transactions = Transaction.where(poster_id: current_user.id, state: ["completed"]).order(updated_at: :desc)
    @completed_listing_transactions = poster_completed_transactions.includes(:employee_listing)
  end

  def write_a_review
  end

  private

  def find_transaction
    @transaction = Transaction.find_by(id: params[:id])
  end

  def find_or_create_conversation
    conversation = Conversation.between(current_user.id, @transaction.hirer_id, @transaction.id)
    if conversation.present?
      conversation.first
    else
       Conversation.create!( receiver_id: @transaction.hirer_id,
                                              sender_id: current_user.id,
                                              employee_listing_id: @transaction.employee_listing_id,
                                              transaction_id: @transaction.id
                                            )
    end
  end

  def create_message
    conversation = find_or_create_conversation
    conversation.update_attributes(read: false)
    message = conversation.messages.create(content: params[:message_text], sender_id: current_user.id)
  end

  def ensure_poster
    employee_listing = if params[:transaction].present? && params[:transaction][:employee_listing_id].present?
      EmployeeListing.find_by(id: params[:transaction][:employee_listing_id])
    elsif params[:id].present?
      Transaction.find_by(id: params[:id]).employee_listing
    elsif params[:listing_id].present?
      EmployeeListing.find_by(id: params[:listing_id])
    end
    if employee_listing.present?
      unless current_user == employee_listing.poster
        flash[:error] = "Invalid request"
        redirect_to employee_index_path
      end
    else
      flash[:error] = "Invalid request"
      redirect_to employee_index_path
    end
  end
  
end