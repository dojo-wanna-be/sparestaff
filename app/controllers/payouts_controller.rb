class PayoutsController < ApplicationController

  def step_1; end

  def step_2; end

  def transacion_history
    if current_user.user_type.eql?("hr")
      hirer_transactions = Transaction.where(hirer_id: current_user.id).order(updated_at: :desc)
      @hirer_hiring_transactions = hirer_transactions.where("end_date > ?", Date.today).where(state: [:accepted, :rejected, :created, :cancelled]).includes(:employee_listing)
      @completed_hiring_transactions = hirer_transactions.where(state: [:cancelled,:completed]).includes(:employee_listing)
      @hirer_hiring_transactions.each do |transaction|
        @stripe_payments = transaction.stripe_payments
        @bookings = transaction.bookings
      end
      @bookings = @bookings.order("booking_date desc")
      @stripe_payments = @stripe_payments.order("created_at desc")
    else
      poster_transactions = Transaction.where(poster_id: current_user.id).order(updated_at: :desc)
      @posted_listing_transactions = poster_transactions.where("end_date > ?", Date.today).where(state: [:accepted, :rejected, :created, :cancelled, :completed]).includes(:employee_listing)
      # @completed_listing_transactions = poster_transactions.where(state: [:cancelled,:completed]).includes(:employee_listing)
      @posted_listing_transactions.each do |transaction|
        @stripe_payments = transaction.stripe_payments
        @bookings = transaction.bookings
      end
      if @bookings.present?
        @bookings = @bookings.order("booking_date desc")
      end
      if @stripe_payments.present?
        @stripe_payments = @stripe_payments.order("created_at desc")
      end
    end
  end

  def security
    current_user.update(password: params[:new_password])
  end

  def index
    @payment_method = current_user.stripe_info
    begin
      @stripe_account = Stripe::Account.retrieve('acct_1FolrxE4u5g7rNqu') if(@payment_method.present?  && @payment_method.stripe_account_id)
    rescue e
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
    if params[:notification_about_receive_message].eql?("true")
      val1 = true
    else
      val1 = false
    end
    if params[:notification_about_promotions_on_email].eql?("true")
      val2 = true
    else
      val2 = false
    end
    if params[:notification_about_promotions_on_phone].eql?("true")
      val3 = true
    else
      val3 = false
    end
    updated_preferences = {
      notification_about_receive_message:      val1,
      notification_about_promotions_on_email:  val2,
      notification_about_promotions_on_phone:  val3
    }
      current_user.notification_setting.update(preferences: updated_preferences)
  end
end
