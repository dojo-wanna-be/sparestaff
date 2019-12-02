class StripeCaptureWorker
  include Sidekiq::Worker

  def perform(transaction_id, stripe_payment_id)
    stripe_payment = ChargeForListing.new(transaction_id).captured_true(stripe_payment_id)
  end
end
