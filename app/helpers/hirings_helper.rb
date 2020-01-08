module HiringsHelper
   
  def transaction_time(transaction)
   	transaction.stripe_payments.present? ? (transaction.stripe_payments.last.created_at + 7.days).strftime("%eth %b %Y") : (transaction.start_date + 7.days).strftime("%eth %b %Y")
  end

  def transaction_time_day_before(transaction)
		transaction.stripe_payments.present? ? ((transaction.stripe_payments.last.created_at + 7.days) - 1.days).strftime("%eth %b %Y") : ((transaction.start_date + 7.days) - 1.days).strftime("%eth %b %Y")
  end
end
