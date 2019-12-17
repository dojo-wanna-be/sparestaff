class ChargeForListing
	def initialize(transaction_id)
		@transaction_id = transaction_id
	end
	def charge(frequency)
		transaction = Transaction.find(@transaction_id)
		if transaction.accepted
			hirer = transaction.hirer
			poster = transaction.poster
			Stripe.api_key = ENV['STRIPE_SECRET_KEY']
			cutsomer_id = customer = Stripe::Customer.retrieve(poster.stripe_info.stripe_customer_id).id
			amount = total_amount(transaction)
			fee = poster_service_fee(amount)
			poster_fee = amount - fee
			charge = Stripe::Charge.create(
			  customer:    cutsomer_id,
			  amount:    (amount*100).to_i,
			  description: description(transaction),
			  currency:    'aud',
			  capture: false,
			  destination: {
	        account: hirer.stripe_info.stripe_account_id,
	        amount: (poster_fee*100).to_i
	      }
			)
			stripe_payment = StripePayment.create!(transaction_id: transaction.id, amount: amount, poster_service_fee: poster_fee, stripe_charge_id: charge.id)
			
			if frequency == 'weekly'
	      PaymentWorker.perform_in(1.week, @transaction_id, "weekly") if Date.today + 6.days < transaction.end_date
	    elsif frequency == 'fortnight'
	      PaymentWorker.perform_in(2.weeks, @transaction_id, "fortnight") if Date.today + 13.days < transaction.end_date
	    end	
			if frequency == 'weekly'
				diff = (transaction.end_date - Date.today).to_i > 6 ? 7 : (transaction.end_date - Date.today).to_i + 1
	      StripeCaptureWorker.perform_in(diff.days, @transaction_id, stripe_payment.id)
	    elsif frequency == 'fortnight'
	    	diff = (transaction.end_date - Date.today).to_i > 13 ? 14 : (transaction.end_date - Date.today).to_i + 1
	      StripeCaptureWorker.perform_in(diff.days, @transaction_id, stripe_payment.id)
	    end
	  end
	end

	def captured_true(stripe_payment_id)
		transaction = Transaction.find(@transaction_id)
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

		def get_beginning_day(transaction)
	    Date.today.beginning_of_week(("#{transaction.start_date.strftime("%A").downcase}").to_sym)
	  end
	
		def total_amount(transaction)
			weekday_hours = 0
	    weekend_hours = 0
	    begining_day = get_beginning_day(transaction)
	    transaction.bookings.where(booking_date: (begining_day..begining_day + 6).to_a).each do |booking|
	      if ["monday", "tuesday", "wednesday", "thursday", "friday"].include?(booking.day)
	        weekday_hours += (booking.end_time - booking.start_time)/3600
	      elsif ["sunday", "saturday"].include?(booking.day)
	        weekend_hours += (booking.end_time - booking.start_time)/3600
	      end
	    end
	    (weekday_hours * transaction.employee_listing.weekday_price.to_f) + (weekend_hours * transaction.employee_listing.weekend_price.to_f)
		end

		def description(transaction)
			"#{transaction.poster.name.titleize} charged #{transaction.hirer.company.name} for #{transaction.start_date.strftime('%-m/%-d')}"
		end
end