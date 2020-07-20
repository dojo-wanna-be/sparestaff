class StripeWebhookController < ApplicationController
  skip_before_action :authenticate_user!
  protect_from_forgery :except => :handle_stripe_webhook

  def handle_stripe_webhook
    StripeWebhook.handle_webhook(params)
    respond_to do |format|
      format.html { head :ok }
    end
  end
end
