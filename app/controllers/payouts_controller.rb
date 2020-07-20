class PayoutsController < ApplicationController
  include WillPaginateHelper
  include PayoutsHelper
  def step_1; end

  def step_2; end

  def transaction_history
    payment_method = current_user.stripe_info
    begin
      @stripe_account = Stripe::Account.retrieve(payment_method.stripe_account_id) if (payment_method.present?  && payment_method.stripe_account_id)
    rescue => e
      @stripe_account = nil
    end
    if current_user.user_type.eql?("hr")
      @hirer_transactions = Transaction.where(hirer_id: current_user.id).where(state: [:completed, :cancelled])
      total_payout = 0
      @hirer_transactions.each do |tx|
        tx.stripe_payments.each do |payment|
          total_payout += total_pay_by_hirer(payment)
        end
      end
      @total_payout = total_payout
      @upcoming_hirer_transactions = Transaction.where(hirer_id: current_user.id).where("end_date >= ?", Date.today).where(state: [:accepted]).includes(:employee_listing)
      pending_total_payout = 0
      @upcoming_hirer_transactions.each do |tx|
        pending_total_payout += hirer_weekly_amount(tx)
      end
      @pending_total_payout = pending_total_payout

      transaction_ids = @hirer_transactions.pluck(:id)
      @captured_stripe_payments =  StripePayment.includes(:listing_transaction).where(transaction_id: transaction_ids).order("updated_at desc").paginate(:page => params[:page], :per_page => 8)

      
      upcoming_transaction_ids = @upcoming_hirer_transactions.pluck(:id)
      @uncaptured_stripe_payments = StripePayment.includes(:listing_transaction).where(transaction_id: upcoming_transaction_ids).order("updated_at desc").paginate(:page => params[:page], :per_page => 8)
      # @hirer_hiring_transactions = hirer_transactions.where("end_date > ?", Date.today).where(state: [:accepted, :rejected, :created, :cancelled]).includes(:employee_listing)
      # @completed_hiring_transactions = hirer_transactions.where(state: [:cancelled,:completed]).includes(:employee_listing)
      # @hirer_hiring_transactions.each do |transaction|
      #   @stripe_payments = transaction.stripe_payments
      #   @bookings = transaction.bookings
      # end
      # @bookings = @bookings.order("booking_date desc")
      # @stripe_payments = @stripe_payments.order("created_at desc")
    else
      @poster_transactions = Transaction.where(poster_id: current_user.id).where(state: [:completed, :cancelled])
      total_payout = 0
      @poster_transactions.each do |tx|
        tx.stripe_payments.each do |payment|
          total_payout += total_pay_to_poster(payment)
        end
      end
      @total_payout = total_payout
      @upcoming_poster_transactions = Transaction.where(poster_id: current_user.id).where('end_date >= ?', Date.today).where(state: [:accepted]).includes(:employee_listing)
      pending_total_payout = 0
      @upcoming_poster_transactions.each do |tx|
        pending_total_payout += tx.stripe_payments.where(capture: false).sum(:poster_service_fee)
      end
      @pending_total_payout = pending_total_payout

      transaction_ids = @poster_transactions.pluck(:id)
      @captured_stripe_payments =  StripePayment.includes(:listing_transaction).where(transaction_id: transaction_ids).order("updated_at desc").paginate(:page => params[:page], :per_page => 8)

     upcoming_transaction_ids = @upcoming_poster_transactions.pluck(:id)
      @uncaptured_stripe_payments = StripePayment.includes(:listing_transaction).where(transaction_id: upcoming_transaction_ids).order("updated_at desc").paginate(:page => params[:page], :per_page => 8)
      # @completed_listing_transactions = poster_transactions.where(state: [:cancelled,:completed]).includes(:employee_listing)
      # if !@posted_listing_transactions.blank?
      #   @posted_listing_transactions.each do |transaction|
      #     @stripe_payments = transaction.stripe_payments
      #     @bookings = transaction.bookings
      #   end
      # end
      # if @bookings.present?
      #   @bookings = @bookings.order("booking_date desc")
      # end
      # if @stripe_payments.present?
      #   @stripe_payments = @stripe_payments.order("created_at desc")
      # end
    end
  end

  def security
    if request.method.eql?("POST")
      if current_user.valid_password?(params[:old_password])
        current_user.update(password: params[:new_password])
        flash[:success] = "Password updated successfully!"
        redirect_to root_path
      else
        flash[:error] = "Current password is blank or Invalid!"
        redirect_to security_payouts_path
      end
    end
  end

  def index
    @payment_method = current_user.stripe_info
    @coupons = current_user.coupons
    @inactive_coupons = Coupon.includes(:user_coupons).where(user_coupons: { user_id: current_user.id, active: false })
    begin
      @stripe_account = Stripe::Account.retrieve(@payment_method.stripe_account_id) if (@payment_method.present?  && @payment_method.stripe_account_id)
    rescue => e
      @stripe_account = nil
    end
  end

  def stripe_account; end

  def create
    @account = StripeAccount.new(params, current_user, request.remote_ip).create
      if @account[:success]
        flash[:notice] = @account[:message]
        redirect_to root_path
      else
        @error = @account[:message]
        render action: "stripe_account"
      end
  end

  def add_coupon
    @coupon = Coupon.find(params[:coupon_id])
    @user_coupon = @coupon.user_coupons.find_by(user_id: current_user.id)
    @user_coupon.update(active: true)
    redirect_to payouts_path
  end

  def change_preference
    updated_preferences = {
      notification_about_receive_message:      params[:notification_about_receive_message].eql?("on"),
      notification_about_promotions_on_email:  params[:notification_about_promotions_on_email].eql?("on"),
      notification_about_promotions_on_phone:  params[:notification_about_promotions_on_phone].eql?("on")
    }
    current_user.notification_setting.update(preferences: updated_preferences)
  end
end
