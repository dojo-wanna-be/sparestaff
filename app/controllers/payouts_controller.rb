class PayoutsController < ApplicationController

  def step_1; end

  def step_2; end

  def transacion_history
    poster_transactions = Transaction.where(poster_id: current_user.id).order(updated_at: :desc)
    @posted_listing_transactions = poster_transactions.where("end_date > ?", Date.today).where(state: [:accepted, :rejected, :created, :cancelled]).includes(:employee_listing)
    @completed_listing_transactions = poster_transactions.where(state: [:cancelled,:completed]).includes(:employee_listing)
    # @completed_listing_transactions.each do |transaction|
    #   @stripe_payments = transaction.stripe_payments
    # end
  end

  def security; end

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
    updated_preferences = {
      notification_about_receive_message:      params[:notification_about_receive_message],
      notification_about_promotions_on_email:  params[:notification_about_promotions_on_email],
      notification_about_promotions_on_phone:  params[:notification_about_promotions_on_phone]
    }
      current_user.notification_setting.update(preferences: updated_preferences)
      redirect_to payouts_path
  end

end
