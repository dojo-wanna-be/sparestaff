class StripeRefundAmount
	def initialize(transaction)
	  @transaction = transaction	  
  end

	def stripe_refund_ammount
		if @transaction.stripe_payments.present? 
			if @transaction.stripe_payments.last.capture == "true"
				@charge_id = @transaction.stripe_payments.last.stripe_charge_id
				@amount = if (@transaction.state.eql?("created") && @transaction.created_at + 2.days <= Date.today) || (@transaction.state.eql?("accepted") && @transaction.start_date - 1 <= Date.today)
						@transaction.hirer_weekly_amount
				else
				  @transaction.hirer_weekly_amount - @transaction.service_fee
				end
				refund = Stripe::Refund.create({
				  charge: @charge_id,
				  amount: (@amount*100).to_i,
				})
			end
		end
	end

end