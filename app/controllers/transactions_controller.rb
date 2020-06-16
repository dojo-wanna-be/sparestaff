class TransactionsController < ApplicationController
  include EmployeeListingsHelper

  skip_before_action :authenticate_user!, only: [:check_slot_availability]
  before_action :ensure_company_owner, except: [:check_slot_availability]
  #before_action :ensure_account_id, only: [:create, :initialized, :payment, :request_payment]
  before_action :find_transaction, only: [:initialized, :payment, :request_sent_successfully, :request_payment]
  before_action :ensure_not_poster, only: [:create, :initialized, :payment, :request_payment]
  before_action :find_company, only: [:initialized, :payment]
  before_action :check_valid_coupon, only: :request_payment

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
      if booked_timings[:start_time_slots][booking_day.to_i].present? && booked_timings[:end_time_slots][booking_day.to_i].present? && booking_value["start_time"].present? && booking_value["end_time"].present?
        if (booked_timings[:start_time_slots][booking_day.to_i] & availability_slots[(availability_slots.index(booking_value["start_time"]))...availability_slots.index(booking_value["end_time"])]).present? || (booked_timings[:end_time_slots][booking_day.to_i] & availability_slots[(availability_slots.index(booking_value["start_time"])+1)..availability_slots.index(booking_value["end_time"])]).present?
          continue = false
          break
        end
      end
    end

    if continue
      transaction = TransactionService.new(params, current_user).create
      if transaction.present?
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
      @transaction.update_attributes(probationary_period: params[:transaction].present? ? params[:transaction][:probationary_period] : nil)
      address = @transaction.build_address(address_params).save
      create_message
      redirect_to payment_transaction_path(id: @transaction.id)
    end
  end

  def payment
    @employee_listing = @transaction.employee_listing
    @coupons = Coupon.includes(:user_coupons).where(user_coupons: { user_id: current_user.id, active: true })
    @slot = ""
    all_bookings = @transaction.bookings
    ListingAvailability::DAYS.map{|k,v| v}.each do |day|
      booking = all_bookings.find_by(day: day)
      if booking.present?
        @slot = @slot + Transaction::DAYS_HASH[:"#{day.downcase}"] + " #{booking.start_time.strftime("%H:%M")} - #{booking.end_time.strftime("%H:%M")}, "
      end
    end
  end

  def request_payment
    @employee_listing = @transaction.employee_listing
    begin
      stripe_token = params[:stripe_token]
      card = AddNewCardOnStripe.new(user: current_user, stripe_token: stripe_token).update
      @transaction.update_attribute(:state, "created")
      if params[:coupon].present?
        discount_amount = current_user.coupons.find_by(coupon_code: params[:coupon]).discount
        amount = (@transaction.amount - discount_amount).round(2)
        remaining_amount = (@transaction.remaining_amount - discount_amount).round(2)
        @transaction.update(discount_percent: discount_amount, discount_coupon: params[:coupon],amount: amount, amount_before_discount: @transaction.amount, remaining_amount: remaining_amount)
      end
      message = find_or_create_conversation.messages.last
      TransactionMailer.request_to_hire_email_to_poster(@transaction, @employee_listing, @employee_listing.poster, current_user, message).deliver_later!
      TransactionMailer.request_to_hire_email_to_hirer(@transaction, @employee_listing, current_user).deliver_later!
      HiringRequestWorker.perform_at((@transaction.created_at + 48.hours).to_s, @transaction.id)
      redirect_to request_sent_successfully_transaction_path(id: @transaction.id)
    rescue Exception => e
      flash[:error] = e
      redirect_to root_path
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

  def check_valid_coupon
    if params[:ajax_call].present?
      if params[:coupon].present? && current_user.coupons.where(coupon_code: params[:coupon]).blank?
        @error = true
        #redirect_to payment_transaction_path(params[:id])
      else
        @discount_amount = current_user.coupons.find_by(coupon_code: params[:coupon]).discount
        @transaction = Transaction.find_by(id: params[:id])
        @listing = @transaction.employee_listing
        @discount_weekday_price = @listing.weekday_price.to_f -  @discount_amount
        @discount_weekend_price = @listing.weekend_price.to_f -  @discount_amount
        total_weekly_amount = ((@discount_weekday_price * @transaction.weekday_hours) + (@discount_weekend_price * @transaction.weekend_hours)) - @transaction.tax_withholding_amount_calculate
        @discount_service_fee = total_weekly_amount.to_f * @transaction.commission_from_hirer
        @discount_hirer_weekly_amount = total_weekly_amount + @discount_service_fee
        weekday_total = @discount_weekday_price * @transaction.total_weekday_hours
        weekdend_total = @discount_weekend_price * @transaction.total_weekend_hours
        total_amount = weekday_total + weekdend_total
        @discount_total_service_fee = (total_amount - @transaction.total_tax_withholding) * @transaction.commission_from_hirer
        @discount_total_amount = (total_amount - @transaction.total_tax_withholding) + @discount_total_service_fee
        #@discount_total_amount = @transaction.total_amount.to_f - (@transaction.total_amount.to_f * @discount_percent/100)
      end
    else
      if params[:coupon].present? && current_user.coupons.where(coupon_code: params[:coupon]).blank?
        flash[:error] = "Sorry! you have applied a Invalid or Expired coupon code."
        redirect_to payment_transaction_path(params[:id])
      end
    end
  end

  private

  def company_params
    params.require(:company).permit(
      :name,
      :acn,
      :contact_no
    )
  end

  def address_params
    params.require(:company).permit(
      :address_1,
      :address_2,
      :city,
      :state,
      :post_code,
      :country
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

  # def ensure_account_id
  #   unless current_user.stripe_info.present? && current_user.stripe_info.stripe_account_id.present?
  #     flash[:info] = "Please create an account first"
  #     redirect_to stripe_account_payouts_path
  #   end
  # end

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
    conversation = Conversation.between(@transaction.hirer_id, @transaction.poster_id, @transaction.id)
    if conversation.present?
      conversation.first
    else
      Conversation.create!( receiver_id: @transaction.poster_id,
                            sender_id: @transaction.hirer_id,
                            employee_listing_id: @employee_listing.id,
                            transaction_id: @transaction.id
                          )
    end
  end

  def create_message
    conversation = find_or_create_conversation
    # conversation.update_attributes(read: false)
    if params[:message_text] != ""
      message = conversation.messages.create(content: params[:message_text], sender_id: current_user.id)
    end
  end
end
