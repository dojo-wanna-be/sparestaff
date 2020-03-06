class StripeCaptureWorker
  include Sidekiq::Worker

  def perform(transaction_id, stripe_payment_id)
    tx = Transaction.find_by(id: transaction_id)
    tx.update_column(:state, "completed") if tx.end_date.eql?(Date.today + 1)
    stripe_payment = ChargeForListing.new(transaction_id).captured_true(stripe_payment_id)
  end
end
