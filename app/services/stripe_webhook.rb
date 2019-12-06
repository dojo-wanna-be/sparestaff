class StripeWebhook
	class << self
		def card_expire(params)
			customer_id = params["data"]["object"]["id"]
			customer = StripeInfo.find_by(stripe_customer_id: customer_id)
			if customer.present?
				customer.update_attributes(status: 'card failed')
			end
		end

		def charge_failed(params)
			charge_id = params["data"]["object"]["id"]
			stripe_payment = StripePayment.find_by(stripe_charge_id: charge_id)
			if stripe_payment.present?
				status = if params["type"] == "charge.succeeded"
						"paid"
					elsif params["type"] == "charge.failed"
						"failed"
					elsif params["type"] == "charge.captured"
						"capture"
					end
				stripe_payment.update_attributes(status: status)
			end
		end

		def handle_webhook(params)
			if(["customer.source.expiring"].include?(params["type"]))
				card_expire(params)
			elsif ["charge.captured","charge.failed" "charge.succeeded"].include?(params["type"])
				charge_failed(params)
			end
		end
	end
end