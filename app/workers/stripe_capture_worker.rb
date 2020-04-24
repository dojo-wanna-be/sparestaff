class StripeCaptureWorker
  include Sidekiq::Worker

  def perform(transaction_id, stripe_payment_id)
    tx = Transaction.find_by(id: transaction_id)
    if tx.end_date.eql?(Date.yesterday)
      tx.update_column(:state, "completed")
      TransactionMailer.write_review_mail_to_poster(tx).deliver_later!
      TransactionMailer.write_review_mail_to_hirer(tx).deliver_later!
    end
    stripe_payment = ChargeForListing.new(transaction_id).captured_true(stripe_payment_id)
  end
end
