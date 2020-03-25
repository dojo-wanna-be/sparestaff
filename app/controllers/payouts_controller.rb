class PayoutsController < ApplicationController

  def step_1; end

  def step_2; end

  def transacion_history; end

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

  def change_prefrence
    if params[:notification_about_receive_message].present?
      val1 = true
    else
      val1 = false
    end
    if params[:notification_about_promotions_on_email].present?
      val2 = true
    else
      val2 = false
    end
    if params[:notification_about_promotions_on_phone].present?
      val3 = true
    else
      val3 = false
    end
    current_user.notification_setting.preferences["notification_about_receive_message"] = val1
    current_user.notification_setting.preferences["notification_about_promotions_on_email"] = val2
    current_user.notification_setting.preferences["notification_about_promotions_on_phone"] = val3
  end

end
