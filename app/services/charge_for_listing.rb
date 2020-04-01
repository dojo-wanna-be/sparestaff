class ChargeForListing
  def initialize(transaction_id)
    @transaction_id = transaction_id
  end
  def charge(frequency)
    transaction = Transaction.find(@transaction_id)
    if transaction.accepted
      stripe_payment = create_charge(transaction)
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
    start_date = Date.today - (transaction.frequency.eql?("weekly") ? 7.days : 14.days)
    end_date = Date.today - 1
    if transaction.accepted
      hirer = transaction.hirer
      poster = transaction.poster
      Stripe.api_key = ENV['STRIPE_SECRET_KEY']
      stripe_payment = StripePayment.find(stripe_payment_id)
      begin
        charge = Stripe::Charge.retrieve(stripe_payment.stripe_charge_id)
        result = charge.capture
        stripe_payment.update_attributes(capture: true)
        PaymentReceipt.create(transaction_id: transaction.id, start_date: start_date, end_date: end_date, tx_price: transaction.hirer_weekly_amount)
      rescue Stripe::CardError => e
        error = e.json_body[:error][:message]
      rescue Exception => e
        error = e.message
      end
    end
  end

  def charge_first_time
    transaction = Transaction.find(@transaction_id)
    stripe_payment = create_charge(transaction, 'first_time')
    if transaction.frequency == 'weekly'
      PaymentWorker.perform_in((transaction.start_date + 1.week).to_datetime, @transaction_id, "weekly") if Date.today + 6.days < transaction.end_date
    elsif transaction.frequency == 'fortnight'
      PaymentWorker.perform_in((transaction.start_date + 2.weeks).to_datetime, @transaction_id, "fortnight") if Date.today + 13.days < transaction.end_date
    end 
    if transaction.frequency == 'weekly'
      diff = (transaction.end_date - Date.today).to_i > 6 ? 7 : (transaction.end_date - Date.today).to_i + 1
      StripeCaptureWorker.perform_in((transaction.start_date + diff.days).to_datetime, @transaction_id, stripe_payment.id)
    elsif transaction.frequency == 'fortnight'
      diff = (transaction.end_date - Date.today).to_i > 13 ? 14 : (transaction.end_date - Date.today).to_i + 1
      StripeCaptureWorker.perform_in((transaction.start_date + diff.days).to_datetime, @transaction_id, stripe_payment.id)
    end
  end

  private

    def create_charge(transaction, from=nil)
      hirer = transaction.hirer
      poster = transaction.poster
      Stripe.api_key = ENV['STRIPE_SECRET_KEY']
      cutsomer_id = customer = Stripe::Customer.retrieve(hirer.stripe_info.stripe_customer_id).id
      amount = total_amount(transaction, from)
      amount_with_hirer_service_fee = amount + transaction.service_fee - transaction.tax_withholding_amount
      fee = poster_service_fee(amount)
      poster_fee = amount - fee
      charge = Stripe::Charge.create(
        customer:  cutsomer_id,
        amount:    (amount_with_hirer_service_fee * 100).to_i,
        description: description(transaction),
        currency:    'aud',
        capture: false,
        destination: {
          account: poster.stripe_info.stripe_account_id,
          amount: (poster_fee*100).to_i
        }
      )
      StripePayment.create!(transaction_id: transaction.id, amount: amount, poster_service_fee: poster_fee, stripe_charge_id: charge.id)
    end

    def poster_service_fee amount
      amount * 0.1
    end

    def get_beginning_day(transaction)
      Date.today.beginning_of_week(("#{transaction.start_date.strftime("%A").downcase}").to_sym)
    end
  
    def total_amount(transaction, from = nil)
      if transaction.frequency == 'weekly'
        if(from.present?)
          diff = (transaction.end_date - transaction.start_date).to_i > 6 ? 6 : (transaction.end_date - Date.today).to_i + 1
          calculate_amount(transaction, transaction.start_date, diff)
        else
          begining_day = get_beginning_day(transaction)
          diff = (transaction.end_date - Date.today).to_i > 6 ? 6 : (transaction.end_date - Date.today).to_i + 1
          calculate_amount(transaction, begining_day, diff)
        end
      elsif transaction.frequency == 'fortnight'
        if(from.present?)
          diff = (transaction.end_date - transaction.start_date).to_i > 13 ? 13 : (transaction.end_date - Date.today).to_i + 1
          calculate_amount(transaction, transaction.start_date, diff)
        else
          begining_day = get_beginning_day(transaction)
          diff = (transaction.end_date - Date.today).to_i > 13 ? 13 : (transaction.end_date - Date.today).to_i + 1
          calculate_amount(transaction, begining_day, diff)
        end
      end
    end

    def calculate_amount(transaction, begining_day, diff) 
      weekday_hours = 0
      weekend_hours = 0
      transaction.bookings.where(booking_date: (begining_day..begining_day + diff).to_a).each do |booking|
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