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
                                            :cancel,
                                            :destroy_transaction
                                          ]
  before_action :ensure_repeat_tx, only: [:change_hiring_confirmation]
  before_action :ensure_not_poster, only: [:change_hiring]
  skip_before_action :authenticate_user!, only: [:check_slot_availability]

  def index
    hirer_transactions = Transaction.where(hirer_id: current_user.id).order(updated_at: :desc)
    @hired_listing_transactions = hirer_transactions.where(state: [:created, :accepted, :cancelled]).includes(:employee_listing)
    @past_listing_transactions = hirer_transactions.where(state: [:expired, :completed]).includes(:employee_listing)
    @declined_listing_transactions = hirer_transactions.where(state: "rejected").includes(:employee_listing)
  end

  def show
    @listing = @transaction.employee_listing
    @address = @transaction.address
  end

  def destroy_transaction
    if(@transaction.destroy)
      if(request.xhr?)
        render js: "window.location = '#{root_path}'"
      else
        redirect_to change_hiring_hiring_path(params[:old_id])
      end
    else
      flash[:error] = "Something went to wrong"
      redirect_to change_hiring_confirmation_hiring_path(id: params[:id], old_id: params[:old_id])
    end
  end

  def change_or_cancel
    @listing = @transaction.employee_listing
  end

  def accept
    if @transaction.update_attributes(state: "accepted")
      if(@transaction.old_transaction.present?)
        old_transaction = Transaction.find(@transaction.old_transaction)
        old_transaction.update_attributes(state: "completed", status: false)
      end
      @listing = @transaction.employee_listing
      poster = User.find_by(id: @transaction.poster_id)
      message = create_message
      HiringMailer.employee_hire_confirmation_email_to_poster(@listing, poster, @transaction).deliver_later!
      HiringMailer.employee_hire_confirmation_email_to_hirer(@listing, current_user, @transaction).deliver_later!
      ChargeForListing.new(@transaction.id).charge_first_time   
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
    if @transaction.update_attribute(:state, "rejected")
      @listing = @transaction.employee_listing
      poster = User.find_by(id: @transaction.poster_id)
      conversation = find_or_create_conversation
      message = conversation.messages&.last.present? ? conversation.messages.last : ""
      HiringMailer.employee_hire_declined_email_to_Poster(@listing, poster, @transaction, message).deliver_later!
      HiringMailer.employee_hire_declined_email_to_Hirer(@listing, current_user, @transaction, message).deliver_later!
      redirect_to inbox_path(id: @transaction.conversation.id)
    else
      flash[:error] = "Something went wrong"
      redirect_to inbox_path(id: @transaction.conversation.id)
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
                    .where.not(id: @old_transaction&.id)
      
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
        @new_transaction = TransactionService.new(params, current_user).create
        if @new_transaction.present?
          #@new_transaction.start_date = @old_transaction.start_date
          # @new_transaction.hirer_total_service_fee = @new_transaction.total_service_fee
          # @new_transaction.poster_service_fee = @new_transaction.poster_service_fee
          # @new_transaction.poster_total_service_fee = @new_transaction.poster_total_service_fee

          # @new_transaction.save
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
    @bookings = @transaction.bookings
    @old_transaction = Transaction.find_by(id: params[:old_id])
    refund_charge_id = @old_transaction.stripe_payments.last.stripe_charge_id
    refund_amount = @old_transaction.amount + @old_transaction.service_fee
    #refund_amount = @old_transaction.hirer_weekly_amount
    if request.patch?
      if @transaction.start_date > Date.today
  			begin
  		    ChargeForListing.new(@transaction.id).charge_first_time
  		    begin
  			    refund = Stripe::Refund.create({
  					  charge: refund_charge_id,
  					  amount: (refund_amount*100).to_i,
  					})
  			  rescue => e
  			    # Some other error; display an error message.
  			    flash[:error] = e.error.message
  			  end
  		    # No exceptions were raised; Set our success message.
  		    @transaction.update_attributes(state: "accepted", request_by: 'hirer', old_transaction: params[:old_id])
        	#HiringRequestWorker.perform_at((@transaction.created_at + 48.hours).to_s, @transaction.id)
        	HiringMailer.hiring_changed_email_to_hirer(@listing, current_user, @transaction).deliver_later!
        	message = find_or_create_conversation.messages.last
        	HiringMailer.hiring_changed_email_to_poster(@listing, @listing.poster, @transaction, message).deliver_later!
  		    flash[:notice] = 'Card charged successfully.'
        	redirect_to changed_successfully_hiring_path(id: @transaction.id, old_id: @old_transaction.id)
  		  	
  		  rescue Stripe::CardError => e
  		    # CardError; display an error message.
  		    flash[:notice] = e.error.message
  		  rescue => e
  		    # Some other error; display an error message.
  		    flash[:error] = e.error.message
  		  end
      else
        if (@old_transaction.end_date - @old_transaction.start_date).to_i > 6 && @old_transaction.frequency == "weekly"
          @old_transaction.update(end_date: @old_transaction.start_date + 6.days, state: :completed)
          @transaction.update(start_date: @old_transaction.start_date + 1.week)
          PaymentWorker.perform_at((@transaction.start_date).to_datetime, @transaction.id, @transaction.frequency)
          @transaction.update_attributes(state: "accepted", request_by: 'hirer', old_transaction: params[:old_id])
          #HiringRequestWorker.perform_at((@transaction.created_at + 48.hours).to_s, @transaction.id)
          HiringMailer.hiring_changed_email_to_hirer(@listing, current_user, @transaction).deliver_later!
          message = find_or_create_conversation.messages.last
          HiringMailer.hiring_changed_email_to_poster(@listing, @listing.poster, @transaction, message).deliver_later!
          redirect_to changed_successfully_hiring_path(id: @transaction.id, old_id: @old_transaction.id)
          flash[:success] = "Success! Your changes will be applied at your next cycle."
        elsif (@old_transaction.end_date - @old_transaction.start_date).to_i > 14 && @old_transaction.frequency == "fortnight"
          @old_transaction.update(end_date: @old_transaction.start_date + 13.days, state: :completed)
          @transaction.update(start_date: @old_transaction.start_date + 2.weeks)
          PaymentWorker.perform_at((@transaction.start_date).to_datetime, @transaction.id, @transaction.frequency)
          @transaction.update_attributes(state: "accepted", request_by: 'hirer', old_transaction: params[:old_id])
          #HiringRequestWorker.perform_at((@transaction.created_at + 48.hours).to_s, @transaction.id)
          HiringMailer.hiring_changed_email_to_hirer(@listing, current_user, @transaction).deliver_later!
          message = find_or_create_conversation.messages.last
          HiringMailer.hiring_changed_email_to_poster(@listing, @listing.poster, @transaction, message).deliver_later!
          redirect_to changed_successfully_hiring_path(id: @transaction.id, old_id: @old_transaction.id)
          flash[:success] = "Success! Your changes will be applied at your next cycle."
        else
          flash[:error] = "Sorry! You can not change your hiring."
        end
      end
    end
  end

  def changed_successfully
    @listing = @transaction.employee_listing
    @bookings = @transaction.bookings 
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
    if @transaction.present?
      if @transaction.state.eql?("created")
        @transaction.destroy
        redirect_to hirings_path
      else
        flash[:error] = "You cannot cancel the request"
        redirect_to hirings_path
      end
    else
      flash[:error] = "Record not found"
      redirect_to hirings_path
    end
  end

  def tell_poster
    @listing = @transaction.employee_listing
    if request.patch?
      if params[:reason]
        @transaction.update_attributes(reason: params[:reason], cancelled_by: "hirer", state: "cancelled", cancelled_at: Date.today)
      else
        @transaction.update_attributes(state: "cancelled", cancelled_at: Date.today)
      end
      create_message
      TransactionMailer.hiring_cancelled_email_to_hirer(@listing, current_user, @transaction).deliver_later!
      TransactionMailer.hiring_cancelled_email_to_poster(@listing, @listing.poster, @transaction, current_user).deliver_later!
      redirect_to cancelled_successfully_hirings_path(id: @transaction.id)
    end
  end

  def cancelled_successfully
    @listing = @transaction.employee_listing
    StripeRefundAmount.new(@transaction).stripe_refund_ammount
    conversation = Conversation.between(current_user.id, @listing.poster.id, @transaction.id)
    if conversation.present?
      @conversation = conversation.first
    end
  end

  def send_details
    transaction = Transaction.find_by(id: params[:transaction_id])
    TransactionMailer.send_hiring_details(transaction, params[:email]).deliver_later!
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

  def old_transaction
    Transaction.find_by(id: @transaction&.old_transaction)
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

  def find_or_create_conversation
    conversation = Conversation.between(current_user.id, @transaction.poster_id, @transaction.id)
    if conversation.present?
      conversation.first
    else
       Conversation.create!( receiver_id: @transaction.poster_id,
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

  def ensure_repeat_tx
    @old_transaction = Transaction.find_by(id: params[:old_id])
    if @old_transaction.old_transaction.present?
      flash[:error] = "You can not change again your hiring for now try after sometime!!!"
      redirect_to root_path
    end
  end
end
