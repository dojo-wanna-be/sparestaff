class PayoutsController < ApplicationController

  def step_1; end

  def step_2; end

  def transaction_history
    if current_user.user_type.eql?("hr")
      @hirer_transactions = Transaction.where(hirer_id: current_user.id).order(updated_at: :desc)
      total_payout = 0
      @hirer_transactions.each do |tx|
        total_payout += tx.stripe_payments.where(capture: true).sum(:amount)
      end
      @total_payout = total_payout
      # @hirer_hiring_transactions = hirer_transactions.where("end_date > ?", Date.today).where(state: [:accepted, :rejected, :created, :cancelled]).includes(:employee_listing)
      # @completed_hiring_transactions = hirer_transactions.where(state: [:cancelled,:completed]).includes(:employee_listing)
      # @hirer_hiring_transactions.each do |transaction|
      #   @stripe_payments = transaction.stripe_payments
      #   @bookings = transaction.bookings
      # end
      # @bookings = @bookings.order("booking_date desc")
      # @stripe_payments = @stripe_payments.order("created_at desc")
    else
      @poster_transactions = Transaction.where(poster_id: current_user.id).order(updated_at: :desc)
      total_payout = 0
      @poster_transactions.each do |tx|
        total_payout += tx.stripe_payments.where(capture: true).sum(:poster_service_fee)
      end
      binding.pry
      @total_payout = total_payout
      @posted_listing_transactions = @poster_transactions.where("end_date >= ?", Date.today).where(state: [:accepted, :created, :cancelled]).includes(:employee_listing)
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

  def change_preference
    updated_preferences = {
      notification_about_receive_message:      params[:notification_about_receive_message].eql?("on"),
      notification_about_promotions_on_email:  params[:notification_about_promotions_on_email].eql?("on"),
      notification_about_promotions_on_phone:  params[:notification_about_promotions_on_phone].eql?("on")
    }
    current_user.notification_setting.update(preferences: updated_preferences)
  end
end
