class HiringsController < ApplicationController
  include EmployeeListingsHelper

  before_action :find_transaction, only:  [
                                            :change_or_cancel,
                                            :change_hiring,
                                            :change_hiring_confirmation,
                                            :changed_successfully,
                                            :cancel_hiring,
                                            :tell_poster,
                                            :cancelled_successfully,
                                            :show,
                                            :get_receipt,
                                            :receipt_details,
                                            :accept,
                                            :decline_request,
                                            :decline,
                                            :cancel
                                          ]

  before_action :ensure_not_poster, only: [:change_hiring]
  skip_before_action :authenticate_user!, only: [:check_slot_availability]

  def index
    hirer_transactions = Transaction.where(hirer_id: current_user.id).order(updated_at: :desc)
    @hired_listing_transactions = hirer_transactions.includes(:employee_listing)
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
      poster = User.find_by(id: @transaction.poster_id)
      conversation = Conversation.between(current_user.id, @transaction.poster_id, @transaction.employee_listing_id)
      @conversation = if conversation.present?
        conversation.first
      else
         Conversation.create!( receiver_id: @transaction.poster_id,
                                sender_id: current_user.id,
                                employee_listing_id: @transaction.employee_listing_id
                              )
      end
      if params[:message_text].present?
        message = @conversation.messages.build
        message.content = params[:message_text]
        message.sender_id = current_user.id
        message.save
      end
      HiringMailer.employee_hire_confirmation_email_to_poster(@listing, poster, @transaction).deliver!
      HiringMailer.employee_hire_confirmation_email_to_hirer(@listing, current_user, @transaction).deliver!
      redirect_to inbox_path(id: @transaction.id)
    else
      flash[:error] = "Something went wrong"
      redirect_to inbox_path(id: @transaction.id)
    end
  end

  def decline_request
    @transaction.update_attribute(:reason, params[:reason])
    conversation = Conversation.between(current_user.id, @transaction.poster_id, @transaction.employee_listing_id)
    @conversation = if conversation.present?
      conversation.first
    else
       Conversation.create!( receiver_id: @transaction.poster_id,
                              sender_id: current_user.id,
                              employee_listing_id: @transaction.employee_listing_id
                            )
    end
    if params[:message_text].present?
      message = @conversation.messages.build
      message.content = params[:message_text]
      message.sender_id = current_user.id
      message.save
    end
  end

  def decline
    if @transaction.update_attribute(:state, "rejected")
      @listing = @transaction.employee_listing
      poster = User.find_by(id: @transaction.poster_id)
      conversation = Conversation.between(current_user.id, @transaction.poster_id, @transaction.employee_listing_id)
      @conversation = if conversation.present?
        conversation.first
      else
         Conversation.create!( receiver_id: @transaction.poster_id,
                                sender_id: current_user.id,
                                employee_listing_id: @transaction.employee_listing_id
                              )
      end
      if params[:message_text].present?
        message = @conversation.messages.build
        message.content = params[:message_text]
        message.sender_id = current_user.id
        message.save
      end
      HiringMailer.employee_hire_declined_email_to_Poster(@listing, poster, @transaction, message).deliver!
      HiringMailer.employee_hire_declined_email_to_Hirer(@listing, current_user, @transaction, message).deliver!
      redirect_to inbox_path(id: @transaction.id)
    else
      flash[:error] = "Something went wrong"
      redirect_to inbox_path(id: @transaction.id)
    end
  end

  def change_hiring
    @old_transaction = @transaction
    @listing = @transaction.employee_listing
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
        if booked_timings[:start_time_slots][booking_day.to_i].present? && booked_timings[:end_time_slots][booking_day.to_i].present?
          if (booked_timings[:start_time_slots][booking_day.to_i] & availability_slots[(availability_slots.index(booking_value["start_time"]))...availability_slots.index(booking_value["end_time"])]).present? || (booked_timings[:end_time_slots][booking_day.to_i] & availability_slots[(availability_slots.index(booking_value["start_time"])+1)..availability_slots.index(booking_value["end_time"])]).present?
            continue = false
            break
          end
        end
      end

      if continue
        @new_transaction = TransactionService.new(params, current_user).create
        if @new_transaction.present?
          redirect_to change_hiring_confirmation_hiring_path(id: @new_transaction.id, old_id: @old_transaction.id)
        else
          flash[:error] = "Please check your selected dates and slotes and try again"
          redirect_to change_hiring_hiring_path(id: @old_transaction.id)
        end
      else
        flash[:error] = "Your booking is conflicting from other bookings. Please select different timings"
        redirect_to change_hiring_hiring_path(id: @old_transaction.id)
      end
    end
  end

  def change_hiring_confirmation
    @listing = @transaction.employee_listing
    @old_transaction = Transaction.find_by(id: params[:old_id])
    if request.patch?
      @transaction.update_attribute(:state, "created")
      HiringMailer.hiring_changed_email_to_hirer(@listing, current_user, @transaction).deliver!
      conversation = Conversation.between(@transaction.hirer_id, @transaction.poster_id, @transaction.employee_listing_id)
      if conversation.present?
        @conversation = conversation.first
      else
        @conversation = Conversation.create!( receiver_id: @transaction.hirer_id,
                                              sender_id: @transaction.poster_id,
                                              employee_listing_id: @transaction.employee_listing_id
                                            )
      end
      message = @conversation.messages.last
      HiringMailer.hiring_changed_email_to_poster(@listing, @listing.poster, @transaction, message).deliver!
      redirect_to changed_successfully_hiring_path(id: @transaction.id, old_id: @old_transaction.id)
    end
  end

  def changed_successfully
    @listing = @transaction.employee_listing
    @old_transaction = Transaction.find_by(id: params[:old_id])
  end

  def cancel_hiring
    unless request.patch?
      @listing = @transaction.employee_listing
    else
      @transaction.update_attributes(reason: params[:reason], cancelled_by: "hirer")
      redirect_to tell_poster_hiring_path(id: @transaction.id)
    end
  end

  def cancel
    @transaction.update_attributes(status: false, state: "cancelled", cancelled_at: Date.today)
    redirect_to hirings_path
  end

  def tell_poster
    @listing = @transaction.employee_listing
    if request.patch?
      if params[:reason]
        @transaction.update_attributes(reason: params[:reason], cancelled_by: "hirer", state: "cancelled", cancelled_at: Date.today)
      else
        @transaction.update_attributes(state: "cancelled", cancelled_at: Date.today)
      end
      conversation = Conversation.between(current_user.id, @listing.poster.id, @listing.id)
      if conversation.present?
        @conversation = conversation.first
      else
        @conversation = Conversation.create!( receiver_id: @listing.poster.id,
                                              sender_id: current_user.id,
                                              employee_listing_id: @listing.id
                                            )
      end
      message = @conversation.messages.build
      message.content = params[:message_text]
      message.sender_id = current_user.id
      message.save
      TransactionMailer.hiring_cancelled_email_to_hirer(@listing, current_user, @transaction).deliver!
      TransactionMailer.hiring_cancelled_email_to_poster(@listing, @listing.poster, @transaction, current_user).deliver!
      redirect_to cancelled_successfully_hirings_path(id: @transaction.id)
    end
  end

  def cancelled_successfully
    @listing = @transaction.employee_listing
    conversation = Conversation.between(current_user.id, @listing.poster.id, @listing.id)
    if conversation.present?
      @conversation = conversation.first
    end
  end

  def send_details
    transaction = Transaction.find_by(id: params[:transaction_id])
    TransactionMailer.send_hiring_details(transaction, params[:email]).deliver!
    flash[:notice] = "Shared successfully"
    redirect_to hirings_path
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

  def get_receipt
    @listing = @transaction.employee_listing
  end

  def receipt_details
    @listing = @transaction.employee_listing
  end

  private

  def find_transaction
    @transaction = Transaction.find_by(id: params[:id])
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
