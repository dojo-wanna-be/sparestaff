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
    #start_date = Date.today - (transaction.frequency.eql?("weekly") ? 7.days : 14.days)
    #end_date = transaction.end_date > Date.today - 1 ? Date.today - 1 : transaction.end_date
    if transaction.completed?
      hirer = transaction.hirer
      poster = transaction.poster
      Stripe.api_key = ENV['STRIPE_SECRET_KEY']
      stripe_payment = StripePayment.find(stripe_payment_id)
      begin
        charge = Stripe::Charge.retrieve(stripe_payment.stripe_charge_id)
        result = charge.capture
        stripe_payment.update_attributes(capture: true)
        PaymentReceipt.create(transaction_id: transaction.id, start_date: stripe_payment.payment_cycle_start_date, end_date: stripe_payment.payment_cycle_end_date, tx_price: transaction.hirer_weekly_amount)
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
      amount = ApplicationController.helpers.discount_amount(transaction, total_amount(transaction, from))
      amount_with_hirer_service_fee = amount + (transaction.discount_coupon.present? ? amount * transaction.commission_from_hirer : transaction.service_fee) - transaction.tax_withholding_amount_calculate
      fee = poster_service_fee(amount - transaction.tax_withholding_amount_calculate)
      poster_fee = amount - transaction.tax_withholding_amount_calculate - fee
      if transaction.frequency == 'weekly'
        stripe_payment = StripePayment.create!(transaction_id: transaction.id, amount: amount, poster_service_fee: poster_fee, status: "failed", payment_cycle_start_date: transaction.start_date > Date.today ? transaction.start_date : Date.today, payment_cycle_end_date: transaction.start_date > Date.today ? transaction.start_date + 6.days : ((Date.today + 6.days) < transaction.end_date ? (Date.today + 6.days) : transaction.end_date))
      elsif transaction.frequency == 'fortnight'
        stripe_payment = StripePayment.create!(transaction_id: transaction.id, amount: amount, poster_service_fee: poster_fee, status: "failed", payment_cycle_start_date: transaction.start_date > Date.today ? transaction.start_date : Date.today, payment_cycle_end_date: transaction.start_date > Date.today ? transaction.start_date + 13.days : ((Date.today + 13.days) < transaction.end_date ? (Date.today + 13.days) : transaction.end_date))
      end
      begin
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
        stripe_payment.update(stripe_charge_id: charge.id, status: charge.status, reason: charge.failure_message)
      rescue => e
        stripe_payment.update(reason: e.message)
      end
      failed_payments = transaction.stripe_payments.where.not(status: "succeeded")
      if !failed_payments.blank?
        failed_payments.each do |payment|
          #amount_with_hirer_service_fee = payment.amount + payment.listing_transaction.service_fee - payment.listing_transaction.tax_withholding_amount
          begin
            charge = Stripe::Charge.create(
              customer:  cutsomer_id,
              amount:    (amount_with_hirer_service_fee * 100).to_i,
              description: description(transaction),
              currency:    'aud',
              capture: true,
              destination: {
                account: poster.stripe_info.stripe_account_id,
                amount: (poster_fee*100).to_i
              }
            )
            payment.update(stripe_charge_id: charge.id, status: charge.status, reason: charge.failure_message)
          rescue => e
            payment.update(reason: e.message)
          end
        end
      end
      stripe_payment
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