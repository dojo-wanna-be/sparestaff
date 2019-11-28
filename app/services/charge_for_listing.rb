class ChargeForListing
	
	attr_reader :transaction, :hirer, :poster

	def initialize(transaction, hirer, poster)
		@transaction = transaction
		@hirer = hirer
		@poster = poster 
	end
	
	def charge
		Stripe.api_key = ENV['STRIPE_SECRET_KEY']
		token = Stripe::Token.create(
		  {customer: customer_id},
		  Stripe.api_key
		).id

		amount = total_amount
		fee = poster_service_fee(amount)
		charge = Stripe::Charge.create(
		  source:    token,
		  amount:    amount,
		  description: description,
		  currency:    'aud',
		  capture: false,
		  destination: {
        account: account_id,
        amount: (amount - fee ).to_i
      }
		)
				
	end

	private

		def poster_service_fee amount
			amount * 0.1
		end

		def customer_id
			poster.stripe_info.stripe_customer_id
		end

		def account_id
			hirer.stripe_info.stripe_account_id
		end

		def get_beginning_day
	    Date.today.beginning_of_week(("#{start_date.strftime("%A").downcase}").to_sym)
	  end
	
		def total_amount
			weekday_hours = 0
	    weekend_hours = 0
	    bookings.where(booking_date: (get_beginning_day..get_beginning_day + 6).to_a).each do |booking|
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