class ChargeForListing
	
	attr_reader :transaction_id

	def initialize(transaction_id)
		@transaction_id = transaction_id
	end
	
	def charge(frequency)
		transaction = Transaction.find(transaction_id)
		if transaction.accepted
			hirer = transaction.hirer
			poster = transaction.poster

			Stripe.api_key = ENV['STRIPE_SECRET_KEY']
			token = Stripe::Token.create(
			  {customer: poster.stripe_info.stripe_customer_id},
			  Stripe.api_key
			).id
			amount = total_amount(transaction)
			fee = poster_service_fee(amount)
			poster_service_fee = amount - fee
			charge = Stripe::Charge.create(
			  source:    token,
			  amount:    amount,
			  description: description,
			  currency:    'aud',
			  capture: false,
			  destination: {
	        account: hirer.stripe_info.stripe_account_id,
	        amount: poster_service_fee.to_i
	      }
			)
			stripe_payment = StripePayment.create!(transaction_id: transaction.id, amount: amount, poster_service_fee: poster_service_fee, stripe_charge_id: charge.id)
			
			if frequency == 'weekly'
	      PaymentWorker.perform_at(Date.today + 7.days, transaction_id, "weekly") if Date.today + 6.days < transaction.end_time
	    elsif frequency == 'fortnight'
	      PaymentWorker.perform_at(Date.today + 14.days, transaction_id, "fortnight") if Date.today + 13.days < transaction.end_time
	    end	
			if frequency == 'weekly'
				diff = (transaction.end_date - Date.today).to_i > 6 ? 7 : (transaction.end_date - Date.today).to_i + 1
	      StripeCaptureWorker.perform_at(Date.today + diff.days, transaction_id, stripe_payment_id)
	    elsif frequency == 'fortnight'
	    	diff = (transaction.end_date - Date.today).to_i > 13 ? 14 : (transaction.end_date - Date.today).to_i + 1
	      StripeCaptureWorker.perform_at(Date.today + diff.days, transaction_id, stripe_payment_id)
	    end
	  end
	end

	def captured_true(stripe_payment_id)
		transaction = Transaction.find(transaction_id)
		if transaction.accepted
			hirer = transaction.hirer
			poster = transaction.poster
			Stripe.api_key = ENV['STRIPE_SECRET_KEY']
			stripe_payment = StripePayment.find(stripe_payment_id)
			begin
	      charge = Stripe::Charge.retrieve(stripe_payment.stripe_charge_id)
	      result = charge.capture
	      stripe_payment.update_attributes(capture: true)
	    rescue Stripe::CardError => e
	      error = e.json_body[:error][:message]
	    rescue Exception => e
	      error = e.message
	    end
	  end
	end

	private

		def poster_service_fee amount
			amount * 0.1
		end

		def get_beginning_day
	    Date.today.beginning_of_week(("#{start_date.strftime("%A").downcase}").to_sym)
	  end
	
		def total_amount(transaction)
			weekday_hours = 0
	    weekend_hours = 0
	    transaction.bookings.where(booking_date: (get_beginning_day..get_beginning_day + 6).to_a).each do |booking|
	      if ["monday", "tuesday", "wednesday", "thursday", "friday"].include?(booking.day)
	        weekday_hours += (booking.end_time - booking.start_time)/3600
	      elsif ["sunday", "saturday"].include?(booking.day)
	        weekend_hours += (booking.end_time - booking.start_time)/3600
	      end
	    end
	    (weekday_hours * employee_listing.weekday_price.to_f) + (weekend_hours * employee_listing.weekend_price.to_f)
		end

		def description
			"#{poster.name.titleize} charged #{hirer.company.name} for #{transaction.start_date.strftime('%-m/%-d')}"
		end
end