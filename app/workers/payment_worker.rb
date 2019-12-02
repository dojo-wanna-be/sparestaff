class PaymentWorker
  include Sidekiq::Worker

  def perform(transaction_id, frequecy)
    stripe_payment = ChargeForListing.new(transaction_id).charge(frequecy)
  end
end
